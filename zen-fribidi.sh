#!/bin/bash

# Copyright (C) 2014 - Romain Bouqueau
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


function fribidi_build {
  host=$1
  pushDir $WORK/src

  lazy_download "fribidi.tar.xz" "http://pkgs.fedoraproject.org/repo/pkgs/fribidi/fribidi-0.19.6.tar.bz2/ce93d862344991173dabb609bf93ca1d/fribidi-0.19.6.tar.bz2"
  lazy_extract "fribidi.tar.xz"
  mkgit "fribidi"
  
  pushDir "fribidi"
  fribidi_patches
  popDir

  autoconf_build $host "fribidi" \
    --enable-shared \
    --disable-static

  popDir
}

function fribidi_get_deps {
  local a=0
}

function fribidi_patches {
  local patchFile=$scriptDir/patches/fribidi_01_ExportSymbolsDup.diff
  cat << 'EOF' > $patchFile
diff -urN lib/Makefile.am fribidi/lib/Makefile.am
--- a/lib/Makefile.am	2012-12-30 00:11:33.000000000 +0000
+++ b/lib/Makefile.am	2014-07-26 16:01:01.785635600 +0100
@@ -7,12 +7,7 @@
 libfribidi_la_LDFLAGS = -no-undefined -version-info $(LT_VERSION_INFO)
 libfribidi_la_LIBADD = $(MISC_LIBS)
 libfribidi_la_DEPENDENCIES =
-
-if OS_WIN32
-libfribidi_la_LDFLAGS += -export-symbols $(srcdir)/fribidi.def
-else
 libfribidi_la_LDFLAGS += -export-symbols-regex "^fribidi_.*"
-endif # OS_WIN32
 
 if FRIBIDI_CHARSETS
 
diff -urN fribidi/lib/Makefile.in fribidi-0.19.6/lib/Makefile.in
--- a/lib/Makefile.in	2013-12-06 20:56:59.000000000 +0000
+++ b/lib/Makefile.in	2014-07-26 16:03:34.860073600 +0100
@@ -79,11 +79,9 @@
 POST_UNINSTALL = :
 build_triplet = @build@
 host_triplet = @host@
-@OS_WIN32_TRUE@am__append_1 = -export-symbols $(srcdir)/fribidi.def
-@OS_WIN32_FALSE@am__append_2 = -export-symbols-regex "^fribidi_.*"
-@FRIBIDI_CHARSETS_TRUE@am__append_3 = -I$(top_srcdir)/charset
-@FRIBIDI_CHARSETS_TRUE@am__append_4 = $(top_builddir)/charset/libfribidi-char-sets.la
-@FRIBIDI_CHARSETS_TRUE@am__append_5 = $(top_builddir)/charset/libfribidi-char-sets.la
+@FRIBIDI_CHARSETS_TRUE@am__append_1 = -I$(top_srcdir)/charset
+@FRIBIDI_CHARSETS_TRUE@am__append_2 = $(top_builddir)/charset/libfribidi-char-sets.la
+@FRIBIDI_CHARSETS_TRUE@am__append_3 = $(top_builddir)/charset/libfribidi-char-sets.la
 DIST_COMMON = $(srcdir)/Headers.mk $(srcdir)/Makefile.in \
 	$(srcdir)/Makefile.am $(srcdir)/fribidi-config.h.in \
 	$(top_srcdir)/depcomp $(pkginclude_HEADERS)
@@ -338,11 +336,11 @@
 top_srcdir = @top_srcdir@
 EXTRA_DIST = fribidi.def
 lib_LTLIBRARIES = libfribidi.la
-AM_CPPFLAGS = $(MISC_CFLAGS) $(am__append_3)
+AM_CPPFLAGS = $(MISC_CFLAGS) $(am__append_1)
 libfribidi_la_LDFLAGS = -no-undefined -version-info $(LT_VERSION_INFO) \
-	$(am__append_1) $(am__append_2)
-libfribidi_la_LIBADD = $(MISC_LIBS) $(am__append_4)
-libfribidi_la_DEPENDENCIES = $(am__append_5)
+	-export-symbols-regex "^fribidi_.*"
+libfribidi_la_LIBADD = $(MISC_LIBS) $(am__append_2)
+libfribidi_la_DEPENDENCIES = $(am__append_3)
 libfribidi_la_headers = \
 		fribidi-arabic.h \
 		fribidi-begindecls.h \
EOF

  applyPatch $patchFile
}
