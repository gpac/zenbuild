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
  libgcrypt_patches
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

function libgcrypt_patches {
  local patchFile=$scriptDir/patches/libgcrypt_01_Asm64bitMov.diff
  cat << 'EOF' > $patchFile
diff --git a/random/rndhw.c b/random/rndhw.c
index e625512..d5d5078 100644
--- a/random/rndhw.c
+++ b/random/rndhw.c
@@ -69,7 +69,7 @@ poll_padlock (void (*add)(const void*, size_t, enum random_origins),
   nbytes = 0;
   while (nbytes < 64)
     {
-#if defined(__x86_64__) && defined(__LP64__)
+#if defined(__x86_64__)// && defined(__LP64__)
       asm volatile
         ("movq %1, %%rdi\n\t"         /* Set buffer.  */
          "xorq %%rdx, %%rdx\n\t"      /* Request up to 8 bytes.  */
@@ -123,7 +123,7 @@ poll_padlock (void (*add)(const void*, size_t, enum random_origins),
 #ifdef USE_DRNG
 # define RDRAND_RETRY_LOOPS	10
 # define RDRAND_INT	".byte 0x0f,0xc7,0xf0"
-# if defined(__x86_64__) && defined(__LP64__)
+# if defined(__x86_64__) //&& defined(__LP64__)
 #  define RDRAND_LONG	".byte 0x48,0x0f,0xc7,0xf0"
 # else
 #  define RDRAND_LONG	RDRAND_INT

EOF

  applyPatch $patchFile
}
