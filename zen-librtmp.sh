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

function librtmp_get_deps {
  local a=0
}

function librtmp_build {
  host=$1
  pushDir $WORK/src
  lazy_git_clone "git://git.ffmpeg.org/rtmpdump" rtmpdump 79459a2b43f41ac44a2ec001139bcb7b1b8f7497

  pushDir rtmpdump/librtmp
  if [ $(uname -s) == "Darwin" ]; then
    librtmp_patches
  fi

  case $host in
    *mingw*)
      $sed -i "s/^SYS=posix/SYS=mingw/" Makefile
      echo "# YO" >> Makefile
      ;;
  esac

  $sed -i "s@^prefix=.*@prefix=$PREFIX/$host@" Makefile
  $sed -i "s@^CRYPTO=.*@@" Makefile

  $MAKE CROSS_COMPILE="$host-"
  $MAKE CROSS_COMPILE="$host-" install

  popDir
  popDir
}

function librtmp_patches {
  local patchFile=$scriptDir/patches/librtmp_01_dylib_install_name.diff
  cat << 'EOF' > $patchFile
--- a/Makefile	2015-09-09 13:29:23.000000000 +0200
+++ b/Makefile	2015-09-09 13:30:34.000000000 +0200
@@ -53,7 +53,7 @@
 SODIR_mingw=$(BINDIR)
 SODIR=$(SODIR_$(SYS))
 
-SO_LDFLAGS_posix=-shared -Wl,-soname,$@
+SO_LDFLAGS_posix=-shared -Wl,-dylib_install_name,$@
 SO_LDFLAGS_darwin=-dynamiclib -twolevel_namespace -undefined dynamic_lookup \
 	-fno-common -headerpad_max_install_names -install_name $(libdir)/$@
 SO_LDFLAGS_mingw=-shared -Wl,--out-implib,librtmp.dll.a
EOF

  applyPatch $patchFile
}
