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

function libsndfile_get_deps {
  local a=0
}

function libsndfile_build {
  host=$1
  pushDir $WORK/src

  lazy_download "libsndfile.tar.gz" "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz"
  lazy_extract "libsndfile.tar.gz"
  mkgit "libsndfile"
  pushDir "libsndfile"
  applyPatch $scriptDir/patches/libsndfile_01_noCarbon.diff
  popDir

  autoconf_build $host "libsndfile" \
      --disable-static \
      --enable-shared \
      --disable-external-libs

  popDir
}

