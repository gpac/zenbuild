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

function build_tre {
  host=$1
  pushDir $WORK/src

  lazy_git_clone "https://github.com/GerHobbelt/libtre.git" libtre 7365bba77910775047c2b349a6533e0da5e5bd80

  autoconf_build $host "libtre" \
      --disable-static \
      --enable-shared

  popDir
}

function build_libsndfile {
  host=$1
  pushDir $WORK/src

  lazy_download "libsndfile.tar.gz" "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz"
  lazy_extract "libsndfile.tar.gz"
  mkgit "libsndfile"

  autoconf_build $host "libsndfile" \
      --disable-static \
      --enable-shared \
      --disable-external-libs

  popDir
}

function build_jack {
  host=$1
  pushDir $WORK/src

  lazy_git_clone "git://github.com/jackaudio/jack2.git" jack2_$host f90f76f

  CFLAGS="-I$PREFIX/$host/include -L$PREFIX/$host/lib"
  CFLAGS+=" -I$PREFIX/$host/include/tre"

  pushDir jack2_$host

  applyPatch $scriptDir/patches/jack_01_OptionalPortAudio.diff
  applyPatch $scriptDir/patches/jack_03_NoExamples.diff
  applyPatch $scriptDir/patches/jack_04_OptionalSampleRate.diff

  CC="$host-gcc $CFLAGS" \
  CXX="$host-g++ $CFLAGS" \
  PREFIX=$PREFIX/$host \
  python2 ./waf configure --winmme --dist-target mingw
  python2 ./waf build
  python2 ./waf install
  popDir
  popDir
}

function build_zlib {

  host=$1
  pushDir $WORK/src
  lazy_download "zlib-$host.tar.gz" "http://zlib.net/zlib-1.2.8.tar.gz"

  lazy_extract "zlib-$host.tar.gz"
  mkgit "zlib-$host"

  pushDir zlib-$host
  CC=$host-gcc \
    AR=$host-ar \
    RANLIB=$host-ranlib \
    ./configure \
    --prefix=$PREFIX/$host \
    --static
  $MAKE
  $MAKE install
  popDir

  popDir
}

function build_librtmp {
  host=$1
  pushDir $WORK/src
  lazy_git_clone "git://git.ffmpeg.org/rtmpdump" rtmpdump 79459a2b43f41ac44a2ec001139bcb7b1b8f7497


  pushDir rtmpdump/librtmp

  sed -i "s/^SYS=posix/SYS=mingw/" Makefile
  sed -i "s@^prefix=.*@prefix=$PREFIX/$host@" Makefile
  sed -i "s@^CRYPTO=.*@@" Makefile

  $MAKE CROSS_COMPILE="$host-"
  $MAKE CROSS_COMPILE="$host-" install

  popDir

  popDir
}

function build_x264 {
  host=$1
  pushDir $WORK/src
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

  popDir
}

function build_libav {
  host=$1
  pushDir $WORK/src

  lazy_git_clone "git://git.libav.org/libav.git" libav a61c2115fb936d50b8b0328d00562fe529a7c46a

  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)

  # remove stupid dependency
  sed -i "s/jack_jack_h pthreads/jack_jack_h/" libav/configure

  # remove GPL checking for x264
  sed -i 's/die_license_disabled gpl libx264/#die_license_disabled gpl libx264/' libav/configure

  mkdir -p libav/build/$host
  pushDir libav/build/$host
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
  popDir

  popDir
}

function build_ffmpeg {
  host=$1
  pushDir $WORK/src

  lazy_git_clone git://source.ffmpeg.org/ffmpeg.git ffmpeg c2eb668617555cb8b8bcfb9796241ada9471ac65

  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)

  # remove stupid dependency
  sed -i "s/jack_jack_h pthreads/jack_jack_h/" ffmpeg/configure

  # remove GPL checking for x264
  sed -i 's/die_license_disabled gpl libx264/#die_license_disabled gpl libx264/' ffmpeg/configure

  mkdir -p ffmpeg/build/$host
  pushDir ffmpeg/build/$host
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
	--enable-avresample \
    --pkg-config=pkg-config \
    --cross-prefix=$host-
  $MAKE
  $MAKE install
  popDir

  popDir
}

