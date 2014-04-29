#!/bin/bash

source abuild.sh

BUILD=$($scriptDir/config.guess | sed 's/-unknown-msys$/-pc-mingw32/')
HOST=$BUILD
printMsg "Build type: $BUILD"

export CFLAGS="-O2"
export CXXFLAGS="-O2"
export LDFLAGS="-s"

installErrorHandler

export GCC_PREFIX="$WORK/gdc-4.8/release"


CACHE=$WORK/cache
mkdir -p $WORK/gdc-4.8/src
mkdir -p $CACHE

if [ -z "$MAKE" ]; then
  MAKE="make"
fi

export MAKE

if isMissing "wget"; then
  echo "wget not installed.  Please install with:"
  echo "pacman -S msys-wget"
  echo "or"
  echo "apt-get install wget"
  exit 1
fi

if isMissing "unzip"; then
  echo "unzip not installed.  Please install with:"
  echo "pacman -S msys/unzip"
  echo "or"
  echo "apt-get install unzip"
  exit 1
fi

if isMissing "tar"; then
  echo "tar not installed.  Please install with:"
  echo "mingw-get install tar"
  echo "or"
  echo "apt-get install tar"
  exit 1
fi

if isMissing "patch"; then
  echo "patch not installed.  Please install with:"
  echo "mingw-get install patch"
  echo "or"
  echo "apt-get install patch"
  exit 1
fi

if isMissing "gcc" ; then
  echo "gcc not installed.  Please install with:"
  echo "pacman -S mingw-gcc"
  echo "or"
  echo "apt-get install gcc"
  exit 1
fi

if isMissing "git" ; then
  echo "git not installed.  Please install with:"
  echo "pacman -S mingw-git"
  echo "or"
  echo "apt-get install git"
  exit 1
fi


function build_runtime
{
  lazy_download "mingw-w64-v3.0.0.tar.bz2" "http://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-v3.0.0.tar.bz2/download"
  lazy_extract "mingw-w64-v3.0.0.tar.bz2"
  mkgit "mingw-w64-v3.0.0"
}

function download_gdc {

  if [ ! -d "$CACHE/GDC" ]; then
    git clone https://github.com/Ace17/GDC.git "$CACHE/GDC" -b $GDC_BRANCH
  fi

  rm -rf GDC
  git clone "$CACHE/GDC" -b $GDC_BRANCH

  pushd GDC

  if [ "$GDC_VERSION" != "" ]; then
    git checkout $GDC_VERSION
  fi

  popd
}

function download_gcc {

  lazy_download "$CACHE/gcc-4.8.2.tar.bz2" "http://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2"
  lazy_extract "gcc-4.8.2.tar.bz2"
  mkgit "gcc-4.8.2"
}

function build_gdc_target {
  pushd gcc-4.8.2/build
  $MAKE all-target
  $MAKE install-target
  popd
}

build_gdc_host
build_runtime
build_gdc_target

uninstallErrorHandler
exit 0

