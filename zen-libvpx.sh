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

function libvpx_build {
  host=$1
  pushDir $WORK/src

  lazy_git_clone https://chromium.googlesource.com/webm/libvpx libvpx c5718a7aa3b5490fbfbc47d6f82e7cb3eed46a1e

  local host2=$(echo $host | $sed "s/x86_64-w64-mingw32/x86_64-win64-gcc/")
  host2=$(echo $host2 | $sed "s/i686-w64-mingw32/x86-win32-gcc/")
  host2=$(echo $host2 | $sed "s/x86_64-linux-gnu/x86_64-linux-gcc/")
  mkdir -p libvpx/build/$host
  pushDir libvpx/build/$host
# CFLAGS+=" -I$PREFIX/$host/include " \
# LDFLAGS+=" -L$PREFIX/$host/lib " \
  ../../configure \
    --target=$host2 \
    --disable-examples \
    --disable-unit-tests \
    --disable-docs \
    --enable-shared \
    --disable-static \
    --prefix=$PREFIX/$host
  $MAKE
  $MAKE install
  popDir

  popDir
}

function libvpx_get_deps {
  local a=0
}

