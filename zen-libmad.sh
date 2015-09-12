#!/bin/bash

# Copyright (C) 2014 - Badr BADRI 
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

function libmad_get_deps {
  local a=0
}

function libmad_build {

  local host=$1
  pushDir $WORK/src

  lazy_download "libmad.tar.gz" "http://sourceforge.net/projects/mad/files/libmad/0.15.1b/libmad-0.15.1b.tar.gz"
  lazy_extract "libmad.tar.gz"

  
  if [ $(uname -s) == "Darwin" ]; then
    gsed -i "s/-fforce-mem//" libmad/configure
    gsed -i "s/-fthread-jumps//" libmad/configure
    gsed -i "s/-fcse-follow-jumps//" libmad/configure
    gsed -i "s/-fcse-skip-blocks//" libmad/configure
    gsed -i "s/-fregmove//" libmad/configure
    gsed -i "s/-march=i486//" libmad/configure
  else
    sed -i "s/-fforce-mem//" libmad/configure
  fi

  autoconf_build $host "libmad"

  popDir

}
