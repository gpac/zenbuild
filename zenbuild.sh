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
#  echo -n "[32m"
  echo $*
#  echo -n "[0m"
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
  patchFile=$1
  printMsg "Patching $patchFile"
  patch  --no-backup-if-mismatch --merge -p1 -i $patchFile
}

function initBuild {
  scriptDir=$(pwd)

  if echo $PATH | grep " " ; then
    echo "Your PATH contain spaces, this may cause build issues."
    echo "Please clean up your PATH and retry."
    exit 3
  fi

  WORK=$1

  if [ -z "$WORK" ] ; then
    echo "Usage: $0 <prefix>"
    exit 1
  fi

  printMsg "Building in: $WORK"
}

function pushDir {
  local dir="$1"
  pushd "$dir" 1>/dev/null 2>/dev/null
}

function popDir {
  popd 1>/dev/null 2>/dev/null
}

initBuild "$@"

