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


function build_zlib_deps {
  local a=0
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

