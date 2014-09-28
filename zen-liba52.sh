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

function build_liba52 {
  host=$1
  pushDir $WORK/src

  lazy_download "liba52.tar.xz" "http://liba52.sourceforge.net/files/a52dec-0.7.4.tar.gz"
  lazy_extract "liba52.tar.xz"

  mkdir -p liba52/build/$host
  pushDir liba52/build/$host
  ../../configure \
    --host=$host \
    --prefix=$PREFIX/$host
  $MAKE
  $MAKE install
  popDir

  popDir
}

function liba52_get_deps {
  local a=0
}

