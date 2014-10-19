#!/bin/bash

# Copyright (C) 2014 - Sebastien Alaiwan
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

function build_vlc {
  host=$1
  pushDir $WORK/src

  lazy_download "vlc.tar.xz" "http://download.videolan.org/pub/videolan/vlc/2.1.5/vlc-2.1.5.tar.xz"
  lazy_extract "vlc.tar.xz"

  mkdir -p vlc/build/$host
  pushDir vlc/build/$host
  CFLAGS+=" -I$PREFIX/$host/include " \
  LDFLAGS+=" -L$PREFIX/$host/lib " \
  ../../configure \
    --host=$host \
    --disable-mad \
    --disable-lua \
    --disable-libgcrypt \
    --prefix=$PREFIX/$host
  $MAKE
  $MAKE install
  popDir

  popDir
}

function vlc_get_deps {
  echo "ffmpeg"
  echo "liba52"
}

