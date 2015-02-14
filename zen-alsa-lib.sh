#!/bin/bash

# Copyright (C) 2014 - Badr BADRI
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

function alsa-lib_get_deps {
  local a=0
}

function alsa-lib_build {
 
  host=$1
  pushDir $WORK/src

  lazy_download "alsa-lib.tar.gz" "ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.0.28.tar.bz2"

  lazy_extract "alsa-lib.tar.gz" 

  autoconf_build $host "alsa-lib"

  popDir

}
