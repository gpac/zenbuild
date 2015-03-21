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


function openhevc_get_deps {
  local a=0
}

function openhevc_build {
  local host=$1
  pushDir $WORK/src

  lazy_git_clone "https://github.com/OpenHEVC/openHEVC" openhevc
  
  pushDir openhevc
  mkdir build
  pushDir build
  
  echo "SET(CMAKE_C_COMPILER $host-gcc)" > config.cmake
  echo "SET(CMAKE_CXX_COMPILER $host-g++)" >> config.cmake
  echo "SET(CMAKE_RC_COMPILER $host-windres)" >> config.cmake
  echo "" >> config.cmake

  cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_TOOLCHAIN_FILE=config.cmake -DCMAKE_INSTALL_PREFIX=$PREFIX/$host ..
  $MAKE 
  $MAKE install 
  
  popDir
  popDir
  popDir
 
}
