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

function build_libfdk-aac {
  host=$1
  pushDir $WORK/src

  lazy_download "fdk-aac.tar.gz" "http://sourceforge.net/projects/opencore-amr/files/fdk-aac/fdk-aac-0.1.3.tar.gz"
  lazy_extract "fdk-aac.tar.gz"

  mkgit "fdk-aac"

  autoconf_build $host "fdk-aac" --disable-shared
  popDir
}

function libfdk-aac_get_deps {
  local a=0;
}