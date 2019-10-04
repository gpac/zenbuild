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

function libopenjpeg_build {
  local host=$1
  pushDir $WORK/src

  set -x

  lazy_git_clone https://github.com/gpac-buildbot/OpenJPEG.git libopenjpeg master

  mkdir -p libopenjpeg/build/$host
  pushDir libopenjpeg/build/$host

  echo "" > config.cmake
  case $host in
    *mingw*)
      echo "SET(CMAKE_SYSTEM_NAME Windows)" >> config.cmake
      ;;
  esac

  echo "SET(CMAKE_C_COMPILER $host-gcc)" >> config.cmake
  echo "SET(CMAKE_CXX_COMPILER $host-g++)" >> config.cmake
  echo "SET(CMAKE_RC_COMPILER $host-windres)" >> config.cmake
  echo "SET(CMAKE_ASM_YASM_COMPILER yasm)" >> config.cmake
  echo 'SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DOPJ_STATIC")' >> config.cmake



  cmake -G "Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=config.cmake -DCMAKE_INSTALL_PREFIX=$PREFIX/$host -DCMAKE_BUILD_TYPE=Release ../../
  $MAKE SHELL="sh -x"
  $MAKE install


  set +x

  popDir
  popDir
}

function libopenjpeg_get_deps {
 local a=0
}
