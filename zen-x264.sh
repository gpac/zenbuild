#!/bin/bash

# Copyright (C) 2014 - Sebastien Alaiwan
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


function x264_build {
  local host=$1
  local crossPrefix=$(get_cross_prefix $BUILD $host)

  pushDir $WORK/src
  lazy_git_clone "git://git.videolan.org/x264.git" x264 40bb56814e56ed342040bdbf30258aab39ee9e89

  autoconf_build $host "x264" \
    --enable-static \
    --enable-pic \
    --disable-gpl \
    --disable-cli \
    --enable-win32thread \
    --enable-strip \
    --disable-avs \
    --disable-swscale \
    --disable-lavf \
    --disable-ffms \
    --disable-gpac \
    --disable-opencl \
    --cross-prefix="$crossPrefix"

  popDir
}

function x264_get_deps {
  local a=0
}

