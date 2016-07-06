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

function libsdl2_get_deps {
  local a=0
}

function libsdl2_build {
  
  local host=$1
  pushDir $WORK/src

  lazy_download "libsdl2.tar.gz" "https://www.libsdl.org/release/SDL2-2.0.4.tar.gz"
  lazy_extract "libsdl2.tar.gz" 
  mkgit "libsdl2"

  pushDir "libsdl2"
  applyPatch $scriptDir/patches/libsdl2_01_D3D11Declarations.diff
  popDir

  autoconf_build $host "libsdl2"

  popDir
}  
