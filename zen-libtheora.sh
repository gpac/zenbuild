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

function libtheora_build {
  host=$1
  pushDir $WORK/src

  lazy_download "libtheora.tar.bz2" "http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2"
  lazy_extract "libtheora.tar.bz2"
  mkgit "libtheora"


  mkdir -p libtheora/build/$host
  pushDir libtheora/build/$host

  ../../configure \
    --build=$BUILD \
    --host=$host \
    --prefix=$PREFIX/$host \
    --enable-shared \
    --disable-static \
    --disable-examples
  $MAKE || true
  $sed -i 's/\(1q \\$export_symbols\)/\1|tr -d \\\\\\\"\\r\\\\\\\"/' libtool
  $MAKE
  $MAKE install

  popDir
  popDir
}

function libtheora_get_deps {
  echo "libogg"
}

