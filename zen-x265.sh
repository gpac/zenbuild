#!/bin/bash

# Copyright (C) 2014 - Romain Bouqueau
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


function x265_get_deps {
  local a=0
}

function build_x265 {
  local host=$1
  local crossPrefix=$(get_cross_prefix $BUILD $host)

  pushDir $WORK/src
  hg clone -r 6879 https://bitbucket.org/multicoreware/x265 x265
  
  pushDir x265/
  #applyPatch $scriptDir/patches/x265_01_version.diff
  applyPatch $scriptDir/patches/x265_02_version.diff
  
  mkdir -p build/$host
  pushDir build/$host

  echo "SET(CMAKE_C_COMPILER $host-gcc)" > config.cmake
  echo "SET(CMAKE_CXX_COMPILER $host-g++)" >> config.cmake
  echo "SET(CMAKE_RC_COMPILER $host-windres)" >> config.cmake
  echo "SET(CMAKE_RANLIB $host-ranlib)" >> config.cmake
  echo "SET(CMAKE_ASM_YASM_COMPILER yasm)" >> config.cmake
  echo "" >> config.cmake
  echo "SET(CMAKE_CXX_FLAGS \"-static-libgcc -static-libstdc++ -static -O3 -s\")" >> config.cmake
  echo "SET(CMAKE_C_FLAGS \"-static-libgcc -static-libstdc++ -static -O3 -s\")" >> config.cmake
  echo "SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS \"-static-libgcc -static-libstdc++ -static -O3 -s\")" >> config.cmake
  echo "SET(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS \"-static-libgcc -static-libstdc++ -static -O3 -s\")" >> config.cmake
  echo "SET(CMAKE_SHARED_LINKER_FLAGS \"-static-libgcc -static-libstdc++ -static -O3 -s\")" >> config.cmake
  
  cmake -G "Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=config.cmake -DCMAKE_INSTALL_PREFIX=$PREFIX/$host ../../source
  #cmake -G "Visual Studio 10" -DCMAKE_INSTALL_PREFIX=$PREFIX/$host ../../source
  $MAKE x265-shared
  $MAKE install
  
  popDir
  popDir
  popDir
}

