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

function gmplib_get_deps {
  local a=0
}

function gmplib_build {
  local host=$1
  pushDir $WORK/src

  lazy_download "gmplib.tar.xz" "https://gmplib.org/download/gmp/gmp-6.0.0a.tar.xz"
  lazy_extract "gmplib.tar.xz"

  if [ $(uname -s) == "Darwin" ]; then
    pushDir gmplib/
	gmplib_patches
    popDir
  fi
  autoconf_build $host "gmplib" 

  popDir
}

function gmplib_patches {
  local patchFile=$scriptDir/patches/gmplib_01_mac_asm.diff
  cat << 'EOF' > $patchFile
--- a/mpn/x86_64/k8/redc_1.asm	2014-03-25 15:37:55.000000000 +0100
+++ a/mpn/x86_64/k8/redc_1.asm	2015-09-11 14:30:57.000000000 +0200
@@ -114,7 +114,7 @@
 
 	JUMPTABSECT
 	ALIGN(8)
-L(tab):	JMPENT(	L(0m4), L(tab))
+L(tab):	JMPENT(	L(0), L(tab))
 	JMPENT(	L(1), L(tab))
 	JMPENT(	L(2), L(tab))
 	JMPENT(	L(3), L(tab))
@@ -397,6 +397,7 @@
 
 
 	ALIGN(16)
+L(0):
 L(0m4):
 L(lo0):	mov	(mp,nneg,8), %rax
 	mov	nneg, i
EOF

  applyPatch $patchFile
}
