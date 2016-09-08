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

function toxcore_build {
  host=$1
  pushDir $WORK/src

  lazy_git_clone "https://github.com/irungentoo/toxcore.git" toxcore 627e4d3aa629038b0e195f2189e9826b32c9531a

  mkdir -p toxcore/build/$host
  pushDir toxcore
  ./autogen.sh
  popDir

  mkdir -p toxcore/build/$host
  pushDir toxcore/build/$host

  CFLAGS+=" -I$PREFIX/$host/include " \
  LDFLAGS+=" -L$PREFIX/$host/lib " \
  ../../configure \
    --enable-static \
    --disable-shared \
    --enable-av \
    --host=$host \
    --prefix=$PREFIX/$host

  $MAKE
  $MAKE install

  popDir
  popDir
}

function toxcore_get_deps {
  echo sodium
  echo opus
  echo libvpx
}
