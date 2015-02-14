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

function sodium_build {
  host=$1
  pushDir $WORK/src

  lazy_download "sodium.tar.gz" "https://github.com/jedisct1/libsodium/releases/download/0.7.0/libsodium-0.7.0.tar.gz"
  lazy_extract "sodium.tar.gz"

  mkgit "sodium"

  mkdir -p sodium/build/$host
  pushDir sodium
  ./autogen.sh
  popDir

  pushDir sodium/build/$host
  ../../configure \
    --enable-static \
    --disable-shared \
    --host=$host \
    --prefix=$PREFIX/$host
  $MAKE
  $MAKE install
  popDir

  popDir
}

function sodium_get_deps {
  local a=0
}

