#!/bin/bash

# Copyright (C) 2014 - Sebastien Alaiwan
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

function vlc_build {
  host=$1
  pushDir $WORK/src

  lazy_download "vlc.tar.xz" "http://download.videolan.org/pub/videolan/vlc/2.2.1/vlc-2.2.1.tar.xz"
  lazy_extract "vlc.tar.xz"
  mkgit "vlc"

  mkdir -p vlc/build/$host
  pushDir vlc/build/$host

  #case $host in
  #  *darwin*)
  #    lazy_download sparkle.tar.bz2 https://github.com/sparkle-project/Sparkle/releases/download/1.11.0/Sparkle-1.11.0.tar.bz2
  #    lazy_extract "sparkle.tar.bz2"
  #    pushDir Sparkle-1.11.0
  #
  #    popDir
  #    ;;
  #esac  

  PATH+=":$PREFIX/$host/bin"
  CFLAGS+=" -I$PREFIX/$host/include " \
  LDFLAGS+=" -L$PREFIX/$host/lib " \
  ../../configure \
    --host=$host \
    --enable-fribidi \
    --disable-lua \
    --prefix=$PREFIX/$host
  $MAKE
  $MAKE install
  popDir

  popDir
}

function vlc_get_deps {
  echo "ffmpeg"
  echo "fribidi"
#  echo "jack"
  echo "liba52"
  echo "libmad"
  #echo "libtheora"
  #echo "libvpx"
  echo "opus"
 
  case $host in
    *mingw*)
      ;;
    *)
      echo "libgcrypt"
      #echo "libxcb"
      #echo "libalsa"
      ;;
  esac
}

