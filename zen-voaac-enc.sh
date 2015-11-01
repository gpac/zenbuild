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

function voaac-enc_build {
  host=$1
  pushDir $WORK/src

  lazy_download "vo-aacenc.tar.gz" "http://sourceforge.net/projects/opencore-amr/files/vo-aacenc/vo-aacenc-0.1.3.tar.gz/download"
  lazy_extract "vo-aacenc.tar.gz"
  mkgit "vo-aacenc"
  
  # mkdir -p vo-aacenc/build/$host
  # pushDir vo-aacenc/build/$host
  # ../../src/vo-aacenc/configure \
	# --host=$HOST \
	# --prefix=$EXTRA_DIR
  # $MAKE
  # $MAKE install
  
  #popDir
  
  autoconf_build $host "vo-aacenc"
  popDir
}

function voaac-enc_get_deps {
  local a=0
}

