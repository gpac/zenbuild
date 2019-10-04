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

function liba52_build {
  host=$1
  pushDir $WORK/src


  lazy_git_clone https://github.com/gpac-buildbot/a52dec liba52 master

  CFLAGS="-w -fPIC -std=gnu89" \
  autoconf_build $host "liba52" \
    --enable-shared \
    --disable-static

  popDir
}

function liba52_get_deps {
  local a=0
}
