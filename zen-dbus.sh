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

function dbus_build {
  host=$1
  pushDir $WORK/src

  lazy_download "dbus.tar.gz" "http://dbus.freedesktop.org/releases/dbus/dbus-1.8.8.tar.gz"
  lazy_extract "dbus.tar.gz"

  mkdir -p dbus/build/$host
  pushDir dbus/build/$host
  CFLAGS+=" -I$PREFIX/$host/include " \
  LDFLAGS+=" -L$PREFIX/$host/lib " \
  ../../configure \
    --host=$host \
    --enable-static \
    --enable-abstract-sockets \
    --disable-shared \
    --prefix=$PREFIX/$host
  $MAKE
  $MAKE install
  popDir

  popDir
}

function dbus_get_deps {
  echo "expat"
}
