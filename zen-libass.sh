#!/bin/bash

# Copyright (C) 2014 - Romain Bouqueau
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

function build_libass {
  host=$1
  pushDir $WORK/src

  lazy_download "libass.tar.xz" "https://github.com/libass/libass/releases/download/0.11.2/libass-0.11.2.tar.xz"
  lazy_extract "libass.tar.xz"

  mkgit "libass"

  autoconf_build $host "libass" 
  popDir
}

function libass_get_deps {
  echo freetype2
  echo fribidi
  echo fontconfig
}
