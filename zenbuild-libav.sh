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

if isMissing "autoreconf"; then
  echo "autoreconf not installed."
  exit 1
fi

if isMissing "wget"; then
  echo "wget not installed.  Please install with:"
  echo "pacman -S msys-wget"
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

if isMissing "svn" ; then
  echo "svn not installed.  Please install with:"
  echo "pacman -S svn"
  echo "or"
  echo "apt-get install svn"
  exit 1
fi

function get_arch {
  host=$1
  echo $host | sed "s/-.*//"
}

function get_os {
  host=$1
  echo $host | sed "s/.*-//"
}

function run_autoreconf {
  echo ""
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

  mkdir -p libsamplerate/build/$host
  pushd libsamplerate/build/$host
  if [ -f .built ] ; then
    printMsg "libsamplerate: already built"
  else
    printMsg "libsamplerate: building..."
    ../../configure --host=$host --disable-sndfile --disable-fftw --prefix=$PREFIX/$host
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
    ../../configure --host=$host --prefix=$PREFIX/$host
    $MAKE
    $MAKE install
    touch .built
  fi
  popd

  popd
}

function build_libsndfile {
  host=$1
  pushd $WORK/src

  lazy_download "libsndfile.tar.gz" "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz"
  lazy_extract "libsndfile.tar.gz"
  mkgit "libsndfile"

  mkdir -p libsndfile/build/$host
  pushd libsndfile/build/$host
  if [ ! -f .built ] ; then
    ../../configure --host=$host --disable-external-libs --prefix=$PREFIX/$host
    $MAKE
    $MAKE install
    touch .built
  fi
  popd

  popd
}

function build_portaudio {
  host=$1
  pushd $WORK/src
  svn checkout -r 1928 "http://subversion.assembla.com/svn/portaudio/portaudio/trunk" "portaudio"
  run_autoreconf "portaudio"

  mkdir -p portaudio/build/$host
  pushd portaudio/build/$host
  if [ -f .built ] ; then
    printMsg "portaudio: already built"
  else
    printMsg "portaudio: building..."
    ../../configure --host=$host --prefix=$PREFIX/$host
    $MAKE
    $MAKE install
    touch .built
  fi
  popd

  popd
}

function build_jack {
  host=$1
  pushd $WORK/src

  lazy_git_clone "git://github.com/jackaudio/jack2.git" jack2_$host f90f76f

  CFLAGS="-I$PREFIX/$host/include -L$PREFIX/$host/lib"
  CFLAGS+=" -I$PREFIX/$host/include/tre"

  pushd jack2_$host
  CC="$host-gcc $CFLAGS" \
  CXX="$host-g++ $CFLAGS" \
  PREFIX=$PREFIX/$host \
  ./waf configure --destdir --winmme --dist-target mingw
  ./waf build
  ./waf install
  popd
  popd
}

function build_libav {
  host=$1
  pushd $WORK/src

  lazy_git_clone "git://git.libav.org/libav.git" libav a61c2115fb936d50b8b0328d00562fe529a7c46a

  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)

  # remove stupid dependency
  sed -i "s/jack_jack_h pthreads/jack_jack_h/" libav/configure

  mkdir -p libav/build/$host
  pushd libav/build/$host
  ../../configure \
    --extra-cflags="-DWIN32=1 -I$PREFIX/$host/include" \
    --extra-ldflags="-L$PREFIX/$host/lib" \
    --arch=$ARCH \
    --enable-indev=jack \
    --target-os=$OS \
    --pkg-config=pkg-config \
    --cross-prefix=$host-
  $MAKE
  popd

  popd
}

function build_all {
  host=$1
  build_libsamplerate $host
  build_tre $host
  build_libsndfile $host
  build_portaudio $host
  build_jack $host
  build_libav $host
}

build_all x86_64-w64-mingw32
build_all i686-w64-mingw32

uninstallErrorHandler
exit 0

