#!/bin/bash

source zenbuild.sh

BUILD=$($scriptDir/config.guess | sed 's/-unknown-msys$/-pc-mingw32/')
HOST=$BUILD
printMsg "Build type: $BUILD"

CFLAGS="-O2"
CXXFLAGS="-O2"
LDFLAGS="-s"

CFLAGS+=" -w"
CXXFLAGS+=" -w"

export CFLAGS
export CXXFLAGS
export LDFLAGS

installErrorHandler

export PREFIX="$WORK/release"
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig


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

function run_autoreconf {
  local dir="$1"
  pushd "$dir"
  autoreconf -fi
  popd
}

function build_libsamplerate {
  host=$1
  pushd $WORK/src

  lazy_download "libsamplerate.tar.gz" "http://www.mega-nerd.com/SRC/libsamplerate-0.1.8.tar.gz"
  lazy_extract "libsamplerate.tar.gz"
  mkgit "libsamplerate"
  run_autoreconf "libsamplerate"

  mkdir -p libsamplerate/build/$host
  pushd libsamplerate/build/$host
  if [ -f .built ] ; then
    printMsg "libsamplerate: already built"
  else
    printMsg "libsamplerate: building..."
    ../../configure --host=$host --disable-sndfile --disable-fftw --prefix=$PREFIX
    $MAKE
    $MAKE install
    touch .built
  fi
  popd

  popd
}

function build_tre {
  host=$1
  pushd $WORK/src

  lazy_git_clone "https://github.com/GerHobbelt/libtre.git" libtre
  run_autoreconf "libtre"

  mkdir -p libtre/build/$host
  pushd libtre/build/$host
  if [ -f .built ] ; then
    printMsg "libtre: already built"
  else
    printMsg "libtre: building..."
    ../../configure --host=$host --prefix=$PREFIX
    $MAKE
    $MAKE install
    touch .built
  fi
  popd

  popd
}

function build_jack {
  pushd $WORK/src

  lazy_git_clone git://github.com/jackaudio/jack2.git jack2_64 f90f76f
  lazy_git_clone git://github.com/jackaudio/jack2.git jack2_32 f90f76f

  CFLAGS="-I$PREFIX/include -L$PREFIX/lib"
  CFLAGS+=" -I$PREFIX/include/tre"

  pushd jack2_64
  CC="x86_64-w64-mingw32-gcc $CFLAGS" \
  CXX="x86_64-w64-mingw32-g++ $CFLAGS" \
  ./waf configure --winmme --dist-target mingw
  popd

  pushd jack2_32
  CC="i686-w64-mingw32-gcc $CFLAGS" \
  CXX="i686-w64-mingw32-g++ $CFLAGS" \
  ./waf configure --winmme --dist-target mingw
  popd

  popd
}

function build_libav {
  host=$1
  pushd $WORK/src

  lazy_git_clone git://git.libav.org/libav.git libav a61c2115fb936d50b8b0328d00562fe529a7c46a

  mkdir -p libav/build/$host
  pushd libav/build/$host
  ../../configure
  $MAKE
  popd

  popd
}

build_libsamplerate i686-w64-mingw32
build_libsamplerate x86_64-w64-mingw32
build_tre x86_64-w64-mingw32
build_jack
# build_libav i686-w64-mingw32
# build_libav x86_64-w64-mingw32

uninstallErrorHandler
exit 0

