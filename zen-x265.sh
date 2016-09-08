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
  x265_patches

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

function x265_patches {
  local patchFile=$scriptDir/patches/x265_02_version.diff
  cat << 'EOF' > $patchFile
diff -r b35a5d8f012b source/cmake/version.cmake
--- a/source/cmake/version.cmake	Sun May 18 15:02:27 2014 +0900
+++ b/source/cmake/version.cmake	Mon Jun 23 11:56:37 2014 +0200
@@ -10,75 +10,4 @@
 set(X265_LATEST_TAG "0.0")
 set(X265_TAG_DISTANCE "0")
 
-if(EXISTS ${CMAKE_SOURCE_DIR}/../.hg_archival.txt)
-    # read the lines of the archive summary file to extract the version
-    file(READ ${CMAKE_SOURCE_DIR}/../.hg_archival.txt archive)
-    STRING(REGEX REPLACE "\n" ";" archive "${archive}")
-    foreach(f ${archive})
-        string(FIND "${f}" ": " pos)
-        string(SUBSTRING "${f}" 0 ${pos} key)
-        string(SUBSTRING "${f}" ${pos} -1 value)
-        string(SUBSTRING "${value}" 2 -1 value)
-        set(hg_${key} ${value})
-    endforeach()
-    if(DEFINED hg_tag)
-        set(X265_VERSION ${hg_tag} CACHE STRING "x265 version string.")
-        set(X265_LATEST_TAG ${hg_tag})
-        set(X265_TAG_DISTANCE "0")
-    elseif(DEFINED hg_node)
-        string(SUBSTRING "${hg_node}" 0 16 hg_id)
-        set(X265_VERSION "${hg_latesttag}+${hg_latesttagdistance}-${hg_id}")
-    endif()
-elseif(HG_EXECUTABLE AND EXISTS ${CMAKE_SOURCE_DIR}/../.hg)
-    execute_process(COMMAND
-        ${HG_EXECUTABLE} log -r. --template "{latesttag}"
-        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
-        OUTPUT_VARIABLE X265_LATEST_TAG
-        ERROR_QUIET
-        OUTPUT_STRIP_TRAILING_WHITESPACE
-        )
-    execute_process(COMMAND
-        ${HG_EXECUTABLE} log -r. --template "{latesttagdistance}"
-        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
-        OUTPUT_VARIABLE X265_TAG_DISTANCE
-        ERROR_QUIET
-        OUTPUT_STRIP_TRAILING_WHITESPACE
-        )
-    execute_process(
-        COMMAND
-        ${HG_EXECUTABLE} log -r. --template "{node|short}"
-        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
-        OUTPUT_VARIABLE HG_REVISION_ID
-        ERROR_QUIET
-        OUTPUT_STRIP_TRAILING_WHITESPACE
-        )
-
-    if(X265_LATEST_TAG MATCHES "^r")
-        string(SUBSTRING ${X265_LATEST_TAG} 1 -1 X265_LATEST_TAG)
-    endif()
-    if(X265_TAG_DISTANCE STREQUAL "0")
-        set(X265_VERSION "${X265_LATEST_TAG}")
-    else()
-        set(X265_VERSION "${X265_LATEST_TAG}+${X265_TAG_DISTANCE}-${HG_REVISION_ID}")
-    endif()
-elseif(GIT_EXECUTABLE AND EXISTS ${CMAKE_SOURCE_DIR}/../.git)
-    execute_process(
-        COMMAND
-        ${GIT_EXECUTABLE} describe --tags --abbrev=0
-        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
-        OUTPUT_VARIABLE X265_LATEST_TAG
-        ERROR_QUIET
-        OUTPUT_STRIP_TRAILING_WHITESPACE
-        )
-
-    execute_process(
-        COMMAND
-        ${GIT_EXECUTABLE} describe --tags
-        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
-        OUTPUT_VARIABLE X265_VERSION
-        ERROR_QUIET
-        OUTPUT_STRIP_TRAILING_WHITESPACE
-        )
-endif()
-
 message(STATUS "x265 version ${X265_VERSION}")
diff -r b35a5d8f012b source/encoder/slicetype.cpp
--- a/source/encoder/slicetype.cpp	Sun May 18 15:02:27 2014 +0900
+++ b/source/encoder/slicetype.cpp	Mon Jun 23 11:56:37 2014 +0200
@@ -420,7 +420,7 @@
     }
 
     /* calculate the frame costs ahead of time for estimateFrameCost while we still have lowres */
-    if (param->rc.rateControlMode != X265_RC_CQP)
+    if ((param->rc.rateControlMode != X265_RC_CQP) && (maxSearch > 0))
     {
         int p0, p1, b;
EOF

  applyPatch $patchFile
}
