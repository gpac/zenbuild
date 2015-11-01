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

function libgcrypt_build {
  local host=$1
  pushDir $WORK/src

  lazy_download "libgcrypt.tar.gz" "ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.4.tar.gz"
  lazy_extract  "libgcrypt.tar.gz"
  mkgit libgcrypt

  pushDir libgcrypt
  applyPatch $scriptDir/patches/libgcrypt_01_Asm64bitMov.diff
  popDir

  CFLAGS+=" -I$PREFIX/$host/include " \
  LDFLAGS+=" -L$PREFIX/$host/lib " \
  autoconf_build $host "libgcrypt" \
    --with-gpg-error-prefix=$PREFIX/$host \
    --enable-shared \
    --disable-static \
    --disable-asm #needed for cross-compiling from Linux to Windows 64 bits

  popDir
}

function libgcrypt_get_deps {
  echo "libgpg-error"
}

