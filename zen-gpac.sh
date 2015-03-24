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

function gpac_build {
  host=$1
  pushDir $WORK/src

  lazy_git_clone https://github.com/gpac/gpac.git gpac a672d89bbc90660

  local OS=$(get_os $host)
  local crossPrefix=$(get_cross_prefix $BUILD $host)

  mkdir -p gpac/build/$host
  pushDir gpac/build/$host

  ../../configure \
    --target-os=$OS \
    --cross-prefix="$crossPrefix" \
    --extra-cflags="-I$PREFIX/$host/include -w -fPIC" \
    --extra-ldflags="-L$PREFIX/$host/lib" \
    --sdl-cfg=":$PREFIX/$host/bin" \
    --disable-jack \
    --enable-amr \
    --prefix=$PREFIX/$host

  $MAKE
  $MAKE install-lib

  popDir
  popDir
}

function gpac_get_deps {
  echo faad2
  echo ffmpeg
  echo freetype2
  echo liba52
  echo libjpeg
  echo libmad
  echo libogg
  #echo libopenjpeg
  echo libpng
  echo libsdl2
  #echo libtheora
  echo libvorbis
  echo libxvidcore
  echo libogg
  echo opencore-amr
#  echo openhevc
  echo zlib
}

