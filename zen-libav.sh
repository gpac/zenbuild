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

LDFLAGS+=" -static-libgcc"
LDFLAGS+=" -static-libstdc++"

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
  echo "autoreconf not installed."
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

function get_arch {
  host=$1
  echo $host | sed "s/-.*//"
}

function get_os {
  host=$1
  echo $host | sed "s/.*-//"
}

function autoconf_build {
  host=$1
  shift
  name=$1
  shift

  printMsg "******************************"

  if [ ! -f $name/configure ] ; then
    printMsg "WARNING: package '$name' has no configure script, running autoreconf"
    pushd $name
    autoreconf -i
    popd
  fi

  mkdir -p $name/build/$host
  pushd $name/build/$host
  if [ -f .built ] ; then
    printMsg "$name: already built"
  else
    printMsg "$name: building..."
    ../../configure \
      --build=$BUILD \
      --host=$host \
      --prefix=$PREFIX/$host \
      "$@"
    $MAKE
    $MAKE install
    touch .built
  fi
  popd
}

function build_tre {
  host=$1
  pushd $WORK/src

  lazy_git_clone "https://github.com/GerHobbelt/libtre.git" libtre 7365bba77910775047c2b349a6533e0da5e5bd80

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

function build_jack {
  host=$1
  pushd $WORK/src

  lazy_git_clone "git://github.com/jackaudio/jack2.git" jack2_$host f90f76f

  CFLAGS="-I$PREFIX/$host/include -L$PREFIX/$host/lib"
  CFLAGS+=" -I$PREFIX/$host/include/tre"

  pushd jack2_$host

  applyPatch $scriptDir/patches/jack_01_OptionalPortAudio.diff
  applyPatch $scriptDir/patches/jack_03_NoExamples.diff
  applyPatch $scriptDir/patches/jack_04_OptionalSampleRate.diff

  CC="$host-gcc $CFLAGS" \
  CXX="$host-g++ $CFLAGS" \
  PREFIX=$PREFIX/$host \
  python2 ./waf configure --winmme --dist-target mingw
  python2 ./waf build
  python2 ./waf install
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
  if [ -f build/.built ] ; then
    printMsg "zlib: already built"
  else
    printMsg "zlib: building..."
    CC=$host-gcc \
    AR=$host-ar \
    RANLIB=$host-ranlib \
    ./configure \
      --prefix=$PREFIX/$host \
      --static
    $MAKE
    $MAKE install
    mkdir -p build
    touch build/.built
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

function check_for_crosschain {
  host=$1

  if isMissing "$host-g++" ; then
    echo "No $host-g++ was found in the PATH."
    exit 1
  fi

  if isMissing "$host-gcc" ; then
    echo "No $host-gcc was found in the PATH."
    exit 1
  fi

  if isMissing "$host-nm" ; then
    echo "No $host-nm was found in the PATH."
    exit 1
  fi

  if isMissing "$host-ar" ; then
    echo "No $host-ar was found in the PATH."
    exit 1
  fi

  if isMissing "$host-strings" ; then
    echo "No $host-strings was found in the PATH."
    exit 1
  fi

  if isMissing "$host-dlltool" ; then
    echo "No $host-dlltool was found in the PATH."
    exit 1
  fi

  if isMissing "$host-as" ; then
    echo "No $host-as was found in the PATH."
    exit 1
  fi

  if isMissing "$host-windres" ; then
    echo "No $host-windres was found in the PATH."
    exit 1
  fi

}

function build_all {
  host=$1

  check_for_crosschain $host

  export PKG_CONFIG_PATH=$PREFIX/$host/lib/pkgconfig
  build_x264 $host
  build_zlib $host
  build_tre $host
  build_libsndfile $host
  build_jack $host
  build_librtmp $host
  build_libav $host
}

build_all x86_64-w64-mingw32
build_all i686-w64-mingw32

uninstallErrorHandler
exit 0

