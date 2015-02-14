#!/bin/bash

# Copyright (C) 2015 - Sebastien Alaiwan
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


function expat_build {
  local host=$1
  pushDir $WORK/src

  lazy_download "expat.tar.xz" "http://sourceforge.net/projects/expat/files/expat/2.1.0/expat-2.1.0.tar.gz/download"
  lazy_extract "expat.tar.xz"
  mkgit "expat"

  mkdir -p expat/build/$host
  pushDir expat/build/$host
  CFLAGS+=" -I$PREFIX/$host/include " \
  LDFLAGS+=" -L$PREFIX/$host/lib " \
  ../../configure \
    --host=$host \
    --prefix=$PREFIX/$host
  $MAKE
  $MAKE install

  popDir
  popDir
}

function expat_get_deps {
  local a=0
}

