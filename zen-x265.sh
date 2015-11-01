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


function x265_build {
  local host=$1
  local crossPrefix=$(get_cross_prefix $BUILD $host)

  pushDir $WORK/src
  if [ ! -d "x264/.hg" ] ; then
    rm -rf x265
    hg clone -r 6879 https://bitbucket.org/multicoreware/x265 x265
  else
    pushDir x265
    hg revert
    popDir
  fi

  pushDir x265/
  applyPatch $scriptDir/patches/x265_02_version.diff

  mkdir -p bin/$host
  pushDir bin/$host

  echo "" > config.cmake
  case $host in
    *mingw*)
      echo "SET(CMAKE_SYSTEM_NAME Windows)" >> config.cmake
      ;;
  esac

  echo "SET(CMAKE_C_COMPILER $host-gcc)" >> config.cmake
  echo "SET(CMAKE_CXX_COMPILER $host-g++)" >> config.cmake
  echo "SET(CMAKE_RC_COMPILER $host-windres)" >> config.cmake
  echo "SET(CMAKE_RANLIB $host-ranlib)" >> config.cmake
  echo "SET(CMAKE_ASM_YASM_COMPILER yasm)" >> config.cmake
  echo "" >> config.cmake
  
  if [ $(uname -s) != "Darwin" ]; then
    echo "SET(CMAKE_CXX_FLAGS \"-static-libgcc -static-libstdc++ -static -O3 -s\")" >> config.cmake
    echo "SET(CMAKE_C_FLAGS \"-static-libgcc -static-libstdc++ -static -O3 -s\")" >> config.cmake
    echo "SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS \"-static-libgcc -static-libstdc++ -static -O3 -s\")" >> config.cmake
    echo "SET(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS \"-static-libgcc -static-libstdc++ -static -O3 -s\")" >> config.cmake
    echo "SET(CMAKE_SHARED_LINKER_FLAGS \"-static-libgcc -static-libstdc++ -static -O3 -s\")" >> config.cmake
  fi

  if [ $(uname -s) == "Darwin" ]; then
    LDFLAGS="" cmake -G "Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=config.cmake -DCMAKE_INSTALL_PREFIX=$PREFIX/$host ../../source
  else
    cmake -G "Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=config.cmake -DCMAKE_INSTALL_PREFIX=$PREFIX/$host ../../source
  fi

  $MAKE x265-shared
  $MAKE install

  popDir
  popDir
  popDir
}

function x265_get_deps {
  local a=0
}

