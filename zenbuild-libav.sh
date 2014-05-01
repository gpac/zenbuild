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


CACHE=$WORK/cache
mkdir -p $CACHE
mkdir -p $WORK/src

if [ -z "$MAKE" ]; then
  MAKE="make"
fi

export MAKE

if isMissing "python2"; then
  echo "python2 not installed.  Please install with:"
  echo "pacman -S python2"
  echo "or"
  echo "apt-get install python2"
  exit 1
fi

if isMissing "autoreconf"; then
  echo "autoreconf not installed."
  exit 1
fi

if isMissing "autopoint"; then
  echo "autopoint not installed.  Please install with:"
  echo "pacman -S gettext-devel"
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
  local dir="$1"
  pushd "$dir"
  autoreconf -i
  popd
}

function autoconf_build {
  host=$1
  shift
  name=$1
  shift

  printMsg "******************************"
  mkdir -p $name/build/$host
  pushd $name/build/$host
  if [ -f .built ] ; then
    printMsg "$name: already built"
  else
    printMsg "$name: building..."
    ../../configure \
      --host=$host \
      --prefix=$PREFIX/$host \
      "$@"
    $MAKE
    $MAKE install
    touch .built
  fi
  popd
}

function build_libsamplerate {
  host=$1
  pushd $WORK/src

  lazy_download "libsamplerate.tar.gz" "http://www.mega-nerd.com/SRC/libsamplerate-0.1.8.tar.gz"
  lazy_extract "libsamplerate.tar.gz"
  mkgit "libsamplerate"

  autoconf_build $host "libsamplerate" \
      --disable-static \
      --enable-shared \
      --disable-sndfile \
      --disable-fftw

  popd
}

function build_tre {
  host=$1
  pushd $WORK/src

  lazy_git_clone "https://github.com/GerHobbelt/libtre.git" libtre
  run_autoreconf "libtre"

  autoconf_build $host "libtre" \
      --disable-static \
      --enable-shared

  popd
}

function build_libsndfile {
  host=$1
  pushd $WORK/src

  lazy_download "libsndfile.tar.gz" "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz"
  lazy_extract "libsndfile.tar.gz"
  mkgit "libsndfile"

  autoconf_build $host "libsndfile" \
      --disable-static \
      --enable-shared \
      --disable-external-libs

  popd
}

function build_portaudio {
  host=$1
  pushd $WORK/src
  lazy_download "portaudio.tar.gz" "http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz"
  lazy_extract "portaudio.tar.gz"
  mkgit "portaudio"

  autoconf_build $host "portaudio" \
      --disable-static \
      --enable-shared

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
  ./waf configure --winmme --dist-target mingw
  ./waf build
  ./waf install
  popd
  popd
}

function build_zlib {

  host=$1
  pushd $WORK/src
  lazy_download "zlib-$host.tar.gz" "http://zlib.net/zlib-1.2.8.tar.gz"

  lazy_extract "zlib-$host.tar.gz"
  mkgit "zlib-$host"

  pushd zlib-$host
  if [ ! -f .built ] ; then
    CC=$host-gcc \
    AR=$host-ar \
    RANLIB=$host-ranlib \
    ./configure \
      --prefix=$PREFIX/$host \
      --static
    $MAKE
    $MAKE install
    touch .built
  fi
  popd

  popd
}

function build_librtmp {
  host=$1
  pushd $WORK/src
  lazy_git_clone "git://git.ffmpeg.org/rtmpdump" rtmpdump 79459a2b43f41ac44a2ec001139bcb7b1b8f7497


  pushd rtmpdump/librtmp

  sed -i "s/^SYS=posix/SYS=mingw/" Makefile
  sed -i "s@^prefix=.*@prefix=$PREFIX/$host@" Makefile
  sed -i "s@^CRYPTO=.*@@" Makefile

  $MAKE CROSS_COMPILE="$host-"
  $MAKE CROSS_COMPILE="$host-" install

  popd

  popd
}

function build_x264 {
  host=$1
  pushd $WORK/src
  lazy_git_clone "git://git.videolan.org/x264.git" x264

  autoconf_build $host "x264" \
    --enable-shared \
    --disable-gpl \
    --disable-cli \
    --enable-win32thread \
    --enable-strip \
    --disable-avs \
    --disable-swscale \
    --disable-lavf \
    --disable-ffms \
    --disable-gpac \
    --disable-opencl \
    --cross-prefix="$host-"

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

  # remove GPL checking for x264
  sed -i 's/die_license_disabled gpl libx264/#die_license_disabled gpl libx264/' libav/configure

  mkdir -p libav/build/$host
  pushd libav/build/$host
  ../../configure \
    --arch=$ARCH \
    --target-os=$OS \
    --prefix=$PREFIX/$host \
    --extra-cflags="-DWIN32=1 -I$PREFIX/$host/include" \
    --extra-ldflags="-L$PREFIX/$host/lib" \
    --disable-debug \
    --disable-static \
    --enable-shared \
    --enable-indev=jack \
    --enable-librtmp \
    --disable-gpl \
    --enable-libx264 \
    --disable-gnutls \
    --disable-openssl \
    --pkg-config=pkg-config \
    --cross-prefix=$host-
  $MAKE
  $MAKE install
  popd

  popd
}

function build_all {
  host=$1
  export PKG_CONFIG_PATH=$PREFIX/$host/lib/pkgconfig
  build_x264 $host
  build_zlib $host
  build_libsamplerate $host
  build_tre $host
  build_libsndfile $host
  build_portaudio $host
  build_jack $host
  build_librtmp $host
  build_libav $host
}

build_all x86_64-w64-mingw32
build_all i686-w64-mingw32

uninstallErrorHandler
exit 0

