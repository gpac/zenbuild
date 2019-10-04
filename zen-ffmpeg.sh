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

function ffmpeg_build {
  host=$1
  pushDir $WORK/src

  lazy_git_clone git://source.ffmpeg.org/ffmpeg.git ffmpeg n4.1.4

  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)

  local os=$OS
  case $OS in
    darwin*)
      os="darwin"
      ;;
  esac
  set -x
  # remove stupid dependency
  $sed -i "s/jack_jack_h pthreads/jack_jack_h/" ffmpeg/configure

  mkdir -p ffmpeg/build/$host
  pushDir ffmpeg/build/$host

  LDFLAGS="-L$PREFIX/$host/lib -lz" \
  ../../configure \
      --prefix=$PREFIX/$host \
      --enable-pthreads \
      --disable-w32threads \
      --disable-debug \
      --disable-static \
      --enable-shared \
      --enable-fontconfig \
      --enable-librtmp \
      --enable-gpl \
      --enable-libx264 \
      --enable-zlib \
      --disable-gnutls \
      --disable-openssl \
      --disable-gnutls \
      --disable-openssl \
      --disable-iconv \
      --disable-bzlib \
      --disable-lzma \
      --disable-programs \
      --enable-libaom  \
      --pkg-config=pkg-config \
      --target-os=$os \
      --arch=$ARCH \
      --cross-prefix=$host-
  $MAKE
  $MAKE install
  set +x
  popDir

  popDir
}

function ffmpeg_get_deps {
  #echo libass
  echo fontconfig
  echo librtmp
  echo libpthread
  echo aom
  echo x264
  echo zlib
}
