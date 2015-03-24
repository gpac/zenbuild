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


function tre_get_deps {
  local a=0
}

function tre_build {
  host=$1
  pushDir $WORK/src

  lazy_git_clone "https://github.com/GerHobbelt/libtre.git" libtre 7365bba77910775047c2b349a6533e0da5e5bd80

  pushDir libtre

  autoreconf -fiv

  mkdir -p build/$host
  pushDir build/$host

  ../../configure \
    --build=$BUILD \
    --host=$host \
    --prefix=$PREFIX/$host \
    --enable-shared \
    --disable-static \
    --disable-adplug
  $MAKE
  $MAKE install

  popDir
  popDir
}

