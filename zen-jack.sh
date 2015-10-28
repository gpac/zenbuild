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


function jack_get_deps {
  echo libsndfile
  echo tre
}

function jack_build {
  host=$1
  pushDir $WORK/src

  lazy_git_clone "git://github.com/jackaudio/jack2.git" jack2_$host 9159e9f85f1b85df525c3bc95260e51c72ef9d65 --depth=100

  CFLAGS="-I$PREFIX/$host/include -L$PREFIX/$host/lib"

  pushDir jack2_$host

  applyPatch $scriptDir/patches/jack_01_OptionalPortAudio.diff
  applyPatch $scriptDir/patches/jack_03_NoExamples.diff
  applyPatch $scriptDir/patches/jack_04_OptionalSampleRate.diff
  sed_cmd -i "s/.*tests.*//" wscript
  sed_cmd -i "s/.*example-clients.*//" wscript

  local options=""

  case $host in
    *mingw*)
      CFLAGS+=" -I$PREFIX/$host/include/tre"
      options+=" --winmme --dist-target mingw"
      ;;
  esac

  CC="$host-gcc $CFLAGS" \
  CXX="$host-g++ $CFLAGS" \
  PREFIX=$PREFIX/$host \
  ./waf configure $options
  ./waf build
  ./waf install
  popDir
  popDir
}

