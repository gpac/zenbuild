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

function libav_build {
  host=$1
  pushDir $WORK/src

  lazy_git_clone "git://git.libav.org/libav.git" libav a61c2115fb936d50b8b0328d00562fe529a7c46a

  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)

  # remove stupid dependency
  $sed -i "s/jack_jack_h pthreads/jack_jack_h/" libav/configure

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
    --enable-libfontconfig \
    --enable-librtmp \
    --enable-gpl \
    --enable-libx264 \
    --enable-libx265 \
    --enable-zlib \
    --disable-gnutls \
    --disable-openssl \
    --disable-gnutls \
    --disable-openssl \
    --disable-bzlib \
    --pkg-config=pkg-config \
    --cross-prefix=$host-
  $MAKE
  #$MAKE install
  popDir

  popDir
}

function libav_get_deps {
  echo fontconfig
  echo jack
  echo librtmp
  echo libpthread
  echo x264
  echo x265
  echo zlib
}

