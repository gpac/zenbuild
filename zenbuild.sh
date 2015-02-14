#!/bin/bash

# Copyright (C) 2014 - Sebastien Alaiwan
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

set -e

function prefixLog {
  pfx=$1
  shift
  "$@" 2>&1 | sed -u "s/^.*$/$pfx&/"
}

function printMsg
{
  echo -n "[32m"
  echo $*
  echo -n "[0m"
}

function isMissing
{
  progName=$1
  echo -n "Checking for $progName ... "
  if which $progName 1>/dev/null 2>/dev/null; then
    echo "ok"
    return 1
  else
    return 0
  fi
}

function installErrorHandler
{
  trap "printMsg 'Spawning a rescue shell in current build directory'; PS1='\\w: rescue$ ' bash --norc" EXIT
}

function uninstallErrorHandler
{
  trap - EXIT
}

function lazy_download
{
  local file="$1"
  local url="$2"

  if [ ! -e "$CACHE/$file" ]; then
    wget "$url" -c -O "$CACHE/${file}.tmp"
    mv "$CACHE/${file}.tmp" "$CACHE/$file"
  fi
}

function lazy_extract
{
  local archive="$1"
  echo -n "Extracting $archive ... "
  local name=$(basename $archive .tar.gz)
  name=$(basename $name .tar.bz2)
  name=$(basename $name .tar.xz)

  if [ -d $name ]; then
    echo "already extracted"
  else
    rm -rf ${name}.tmp
    mkdir ${name}.tmp
    tar -C ${name}.tmp -xlf "$CACHE/$archive"  --strip-components=1
    mv ${name}.tmp $name
    echo "ok"
  fi
}

function lazy_git_clone {
  local url="$1"
  local to="$2"
  local rev="$3"

  if [ -d "$to" ] ;
  then
    pushDir "$to"
    git reset -q --hard
    git clean -q -f
    popDir
  else
    git clone "$url" "$to"
  fi

  pushDir "$to"
  git checkout -q $rev
  popDir
}
# Create or restore a directory content
function mkgit {
  dir="$1"

  pushDir "$dir"
  if [ -d ".git" ]; then
    printMsg "Restoring $dir from git restore point"
    git reset -q --hard
    git clean -q -f
  else
    printMsg "Creating git for $dir"
    git init
    git config user.email "nobody@localhost"
    git config user.name "Nobody"
    git config core.autocrlf false
    git add -f *
    git commit -m "MinGW/GDC restore point"
  fi
  popDir
}

function applyPatch {
  local patchFile=$1
  printMsg "Patching $patchFile"
  patch  --no-backup-if-mismatch --merge -p1 -i $patchFile
}

function main {
  BUILD=$($scriptDir/config.guess | sed 's/-unknown//' | sed 's/-msys$/-mingw32/')

  local packageName=$2
  local hostPlatform=$3

  if [ -z "$1" ] || [ -z "$packageName" ] || [ -z "$hostPlatform" ] ; then
    echo "Usage: $0 <workDir> <packageName> <hostPlatform>"
    echo "Example: $0 /tmp/work libav i686-w64-mingw32"
    exit 1
  fi

  mkdir -p "$1"
  WORK=$(get_abs_dir "$1")

  if echo $PATH | grep " " ; then
    echo "Your PATH contain spaces, this may cause build issues."
    echo "Please clean-up your PATH and retry."
    echo "Example:"
    echo "$ PATH=/mingw32/bin:/bin:/usr/bin ./zenbuild.sh <options>"
    exit 3
  fi

  printMsg "Building in: $WORK"

  printMsg "Build platform: $BUILD"
  printMsg "Target platform: $hostPlatform"

  checkForCrossChain "$BUILD" "$hostPlatform"
  checkForCommonBuildTools

  CACHE=$WORK/cache
  mkdir -p $CACHE
  mkdir -p $WORK/src

  export PREFIX="$WORK/release"

  initCflags
  installErrorHandler

  build ${hostPlatform} ${packageName}

  uninstallErrorHandler
}

function initCflags {

  # avoid interferences from environment
  unset CC
  unset CXX
  unset CFLAGS
  unset CXXFLAGS
  unset LDFLAGS

  CFLAGS="-O2"
  CXXFLAGS="-O2"
  LDFLAGS="-s"

  CFLAGS+=" -w"
  CXXFLAGS+=" -w"

  LDFLAGS+=" -static-libgcc"
  LDFLAGS+=" -static-libstdc++"

  export CFLAGS
  export CXXFLAGS
  export LDFLAGS

  if [ -z "$MAKE" ]; then
    MAKE="make"
  fi

  export MAKE
}

function importPkgScript {
  local name=$1
  if ! test -f zen-${name}.sh; then
    echo "Package $name does not have a zenbuild script"
    exit 1
  fi

  source zen-${name}.sh
}

function lazy_build {
  local host=$1
  local name=$2

  export PKG_CONFIG_PATH=$PREFIX/$host/lib/pkgconfig
  export PKG_CONFIG_LIBDIR=$PREFIX/$host/lib/pkgconfig

  if is_built $host $name ; then
    printMsg "$name: already built"
    return
  fi

  importPkgScript $name

  printMsg "$name: building ..."

  local deps=$(${name}_get_deps)
  for depName in $deps ; do
    build $host $depName
  done

  ${name}_build $host

  printMsg "$name: build OK"
  mark_as_built $host $name
}

function mark_as_built {
  local host=$1
  local name=$2

  local flagfile="$WORK/flags/$host/${name}.built"
  mkdir -p $(dirname $flagfile)
  touch $flagfile
}

function is_built {
  local host=$1
  local name=$2

  local flagfile="$WORK/flags/$host/${name}.built"
  if [ -f "$flagfile" ] ;
  then
    return 0
  else
    return 1
  fi
}

function autoconf_build {
  local host=$1
  shift
  local name=$1
  shift

  if [ ! -f $name/configure ] ; then
    printMsg "WARNING: package '$name' has no configure script, running autoreconf"
    pushDir $name
    autoreconf -i
    popDir
  fi

  mkdir -p $name/build/$host
  pushDir $name/build/$host
  ../../configure \
    --build=$BUILD \
    --host=$host \
    --prefix=$PREFIX/$host \
    "$@"
  $MAKE
  $MAKE install
  popDir
}

function build {
  local host=$1
  local name=$2
#  prefixLog "[$name] " \
    lazy_build $host $name
}

function pushDir {
  local dir="$1"
  pushd "$dir" 1>/dev/null 2>/dev/null
}

function popDir {
  popd 1>/dev/null 2>/dev/null
}

function get_cross_prefix {
  local build=$1
  local host=$2
  if [ ! "$build" = "$host" ] ; then
    echo "$host-"
  fi
}

function checkForCrossChain {
  local build=$1
  local host=$2

  local cross_prefix=$(get_cross_prefix $build $host)

  # ------------- GCC -------------
  if isMissing "${cross_prefix}g++" ; then
    echo "No ${cross_prefix}g++ was found in the PATH."
    exit 1
  fi

  if isMissing "${cross_prefix}gcc" ; then
    echo "No ${cross_prefix}gcc was found in the PATH."
    exit 1
  fi

  # ------------- Binutils -------------
  if isMissing "${cross_prefix}nm" ; then
    echo "No ${cross_prefix}nm was found in the PATH."
    exit 1
  fi

  if isMissing "${cross_prefix}ar" ; then
    echo "No ${cross_prefix}ar was found in the PATH."
    exit 1
  fi

  if isMissing "${cross_prefix}strip" ; then
    echo "No ${cross_prefix}strip was found in the PATH."
    exit 1
  fi

  if isMissing "${cross_prefix}strings" ; then
    echo "No ${cross_prefix}strings was found in the PATH."
    exit 1
  fi

  if isMissing "${cross_prefix}as" ; then
    echo "No ${cross_prefix}as was found in the PATH."
    exit 1
  fi

  local os=$(get_os "$host")
  if [ $os = "mingw32" ] ; then
    if isMissing "${cross_prefix}dlltool" ; then
      echo "No ${cross_prefix}dlltool was found in the PATH."
      exit 1
    fi

    if isMissing "${cross_prefix}windres" ; then
      echo "No ${cross_prefix}windres was found in the PATH."
      exit 1
    fi
  fi
}

function checkForCommonBuildTools {
  if isMissing "pkg-config"; then
    echo "pkg-config not installed.  Please install with:"
    echo "pacman -S pkgconfig"
    echo "or"
    echo "apt-get install pkg-config"
    exit 1
  fi

  if isMissing "patch"; then
    echo "patch not installed.  Please install with:"
    echo "pacman -S patch"
    echo "or"
    echo "apt-get install patch"
    exit 1
  fi

  if isMissing "python2"; then
    echo "python2 not installed.  Please install with:"
    echo "pacman -S python2"
    echo "or"
    echo "apt-get install python2"
    exit 1
  fi

  if isMissing "autoreconf"; then
    echo "autoreconf not installed. Please install with:"
    echo "pacman -S autoconf"
    echo "or"
    echo "apt-get install autoconf"
    exit 1
  fi

  if isMissing "libtool"; then
    echo "libtool not installed.  Please install with:"
    echo "pacman -S msys/libtool"
    echo "or"
    echo "apt-get install libtool"
    exit 1
  fi

  if isMissing "make"; then
    echo "make not installed.  Please install with:"
    echo "pacman -S make"
    echo "or"
    echo "apt-get install make"
    exit 1
  fi

  if isMissing "cmake"; then
    echo "make not installed.  Please install with:"
    echo "pacman -S mingw-cmake"
    echo "or"
    echo "apt-get install cmake"
    exit 1
  fi

  if isMissing "autopoint"; then
    echo "autopoint not installed.  Please install with:"
    echo "pacman -S gettext gettext-devel"
    echo "or"
    echo "apt-get install autopoint"
    exit 1
  fi

  if isMissing "yasm"; then
    echo "yasm not installed.  Please install with:"
    echo "apt-get install yasm"
    exit 1
  fi

  if isMissing "wget"; then
    echo "wget not installed.  Please install with:"
    echo "pacman -S msys/wget"
    echo "or"
    echo "apt-get install wget"
    exit 1
  fi

  if isMissing "sed"; then
    echo "sed not installed.  Please install with:"
    echo "pacman -S msys/sed"
    echo "or"
    echo "apt-get install sed"
    exit 1
  fi

  if isMissing "tar"; then
    echo "tar not installed.  Please install with:"
    echo "mingw-get install tar"
    echo "or"
    echo "apt-get install tar"
    exit 1
  fi

  if isMissing "git" ; then
    echo "git not installed.  Please install with:"
    echo "pacman -S mingw-git"
    echo "or"
    echo "apt-get install git"
    exit 1
  fi

  if isMissing "hg" ; then
    echo "git not installed.  Please install with:"
    echo "pacman -S msys/mercurial"
    echo "or"
    echo "apt-get install mercurial"
    exit 1
  fi

  if isMissing "gperf" ; then
    echo "gperf not installed.  Please install with:"
    echo "pacman -S msys/gperf"
    echo "or"
    echo "apt-get install gperf"
    exit 1
  fi
}

function get_arch {
  host=$1
  echo $host | sed "s/-.*//"
}

function get_os {
  host=$1
  echo $host | sed "s/.*-//"
}

function get_abs_dir {
  local relDir="$1"
  pushDir $relDir
  pwd
  popDir
}

# get absolute script dir
scriptDir=$(get_abs_dir $(dirname $0))

main "$@"

