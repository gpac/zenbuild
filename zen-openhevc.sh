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

function openhevc_build {
  local host=$1
  pushDir $WORK/src

  lazy_git_clone https://github.com/OpenHEVC/openHEVC.git openhevc ffmpeg_update

  pushDir openhevc

  set -x

  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)


  ./configure --disable-debug --disable-iconv --enable-pic --prefix=$PREFIX/$host --pkg-config=pkg-config --target-os=$OS --arch=$ARCH --cross-prefix=$host-
  make openhevc-static
  cp -av libopenhevc/libopenhevc.a $PREFIX/$host/lib/


  set +x
  popDir
  popDir
}

function openhevc_get_deps {
  local a=0
}
