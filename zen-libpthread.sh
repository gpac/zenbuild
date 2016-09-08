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
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA

function libpthread_get_deps {
  local a=0
}

function libpthread_build_mingw {
  local host=$1
  pushDir $WORK/src
  
  lazy_download "mingw-w64.tar.bz2" "http://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-v3.1.0.tar.bz2/download"
  lazy_extract "mingw-w64.tar.bz2"
  pushDir mingw-w64/mingw-w64-libraries
  
  autoconf_build $host "winpthreads"
 
  rm $PREFIX/$host/include/pthread.h #remove broken header - will fallback on the pthread correct one
 
  popDir
  popDir
}

function libpthread_build_native {
  local host=$1
  pushDir $WORK/src

  lazy_download "libpthread.tar.bz2" "http://xcb.freedesktop.org/dist/libpthread-stubs-0.1.tar.bz2"
  lazy_extract "libpthread.tar.bz2"
  autoconf_build $host "libpthread"

  popDir
}

function libpthread_build {
  case $host in
    *mingw*)
      libpthread_build_mingw $@
      ;;
    *)
      libpthread_build_native $@
      ;;
  esac
}
