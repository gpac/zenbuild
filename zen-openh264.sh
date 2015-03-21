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

function openh264_get_deps {
  local a=0
}

function openh264_build {

  host=$1
  pushDir $WORK/src
  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)
 
  lazy_git_clone "https://github.com/cisco/openh264" "openh264" 7f967f6fc46290794da02319470afe27e7ed7a6e
  
  pushDir openh264
  
  sed -i "s@^PREFIX=.*@PREFIX=$PREFIX/$host@" Makefile
  sed -i "s@^ARCH=.*@ARCH=$ARCH@" Makefile
  sed -i "s@^OS=.*@OS=$OS@" Makefile
  sed -i "s/gnu/linux/" Makefile
  sed -i "s/mingw32/mingw_nt/" Makefile

  $MAKE
  $MAKE install
  
  popDir
  popDir
}
