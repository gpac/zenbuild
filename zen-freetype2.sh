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

function freetype2_build {
  host=$1
  pushDir $WORK/src

  # lazy_download "freetype2.tar.bz2" "http://download.savannah.gnu.org/releases/freetype/freetype-2.7.1.tar.bz2"
  # lazy_extract "freetype2.tar.bz2"
  # mkgit "freetype2"

  lazy_git_clone https://github.com/gpac-buildbot/freetype freetype2 master

  # pushDir "freetype2"
  # freetype2_patches
  # popDir

  export LDFLAGS="$LDFLAGS -L$PREFIX/$host/lib"
  echo $LDFLAGS
  autoconf_build $host "freetype2" \
    "--without-png" \
    "--enable-shared" \
    "--disable-static"

  popDir
}

function freetype2_get_deps {
  echo zlib
}

# function freetype2_patches {
#   local patchFile=$scriptDir/patches/freetype2_01_pkgconfig.diff
#   cat << 'EOF' > $patchFile
# diff --git a/builds/unix/freetype2.in b/builds/unix/freetype2.in
# index 0d7aefa..e3ae98f 100644
# --- a/builds/unix/freetype2.in
# +++ b/builds/unix/freetype2.in
# @@ -7,5 +7,5 @@ Name: FreeType 2
#  Description: A free, high-quality, and portable font engine.
#  Version: @ft_version@
#  Requires:
# -Libs: -L${libdir} -lfreetype @LIBZ@ @FT2_EXTRA_LIBS@
# +Libs: -L${libdir} -lfreetype @FT2_EXTRA_LIBS@
#  Cflags: -I${includedir}/freetype2 -I${includedir}
# EOF

#   applyPatch $patchFile
# }
