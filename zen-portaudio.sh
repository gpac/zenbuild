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

function portaudio_build {
  host=$1
  pushd $WORK/src
  lazy_download "portaudio.tar.gz" "http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz"
  lazy_extract "portaudio.tar.gz"
  mkgit "portaudio"

  autoconf_build $host "portaudio" \
      --disable-static \
      --enable-shared

  popd
}

function portaudio_get_deps {
  local a=1;
}
