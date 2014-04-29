#!/bin/bash

source zenbuild.sh

BUILD=$($scriptDir/config.guess | sed 's/-unknown-msys$/-pc-mingw32/')
HOST=$BUILD
printMsg "Build type: $BUILD"

export CFLAGS="-O2"
export CXXFLAGS="-O2"
export LDFLAGS="-s"

installErrorHandler

export GCC_PREFIX="$WORK/gdc-4.8/release"


CACHE=$WORK/cache
mkdir -p $CACHE
mkdir -p $WORK/src

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


function build_jack {
  pushd $WORK/src

  lazy_git_clone git://github.com/jackaudio/jack2.git jack2_64 f90f76f
  lazy_git_clone git://github.com/jackaudio/jack2.git jack2_32 f90f76f

  pushd jack2_64
  CC=x86_64-w64-mingw32-gcc \
  CXX=x86_64-w64-mingw32-g++ \
  ./waf configure --dist-target mingw
  popd

  pushd jack2_32
  CC=i686-w64-mingw32-gcc \
  CXX=i686-w64-mingw32-g++ \
  ./waf configure --dist-target mingw
  popd

  popd
}

function build_libav {
  pushd $WORK/src

  lazy_git_clone git://git.libav.org/libav.git libav a61c2115fb936d50b8b0328d00562fe529a7c46a

  mkdir -p libav/build
  pushd libav/build
  ../configure
  $MAKE
  popd

  popd
}

build_libav
build_jack

uninstallErrorHandler
exit 0

