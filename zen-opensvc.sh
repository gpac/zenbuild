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

function opensvc_build {
  local host=$1
  pushDir $WORK/src

  set -x

  lazy_git_clone https://github.com/gpac-buildbot/opensvc.git opensvc master

  pushDir opensvc/svcsvn
  patch -p0 < ../gpac_bb.patch

  mkdir -p build/$host
  pushDir build/$host

  echo "" > config.cmake
  local cmake_type="Unix Makefiles"
  case $host in
    *mingw*)
      echo "SET(CMAKE_SYSTEM_NAME Windows)" >> config.cmake
      cmake_type="MSYS Makefiles"
      ;;
  esac

  echo "SET(CMAKE_C_COMPILER $host-gcc)" >> config.cmake
  echo "SET(CMAKE_CXX_COMPILER $host-g++)" >> config.cmake
  echo "SET(CMAKE_RC_COMPILER $host-windres)" >> config.cmake

  cmake -G "$cmake_type" -DCMAKE_TOOLCHAIN_FILE=config.cmake -DCMAKE_INSTALL_PREFIX=$PREFIX/$host -DCMAKE_BUILD_TYPE=Release  -DCMAKE_C_FLAGS=-fPIC ../../
  $MAKE


  mkdir temp
  cp SVC/lib_svc/CMakeFiles/SVC_baseline.dir/*.obj temp/
  mv temp/slice_data_cabac.c.obj temp/slice_data_cabac_svc.c.obj
  cp AVC/h264_baseline_decoder/lib_baseline/CMakeFiles/AVC_baseline.dir/*.obj temp/
  cp AVC/h264_main_decoder/lib_main/CMakeFiles/AVC_main.dir/*.obj temp/
  cp CommonFiles/src/CMakeFiles/OpenSVCDec.dir/*.obj temp/
  $host-ar cr libOpenSVCDec.a temp/*.obj
  $host-ranlib libOpenSVCDec.a

  cp -av libOpenSVCDec.a $PREFIX/$host/lib/

  set +x

  popDir
  popDir
  popDir
}

function opensvc_get_deps {
#echo "libsdl2"
 local a=0
}
