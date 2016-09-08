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
  pushDir jack2_$host

  jack_patches
  $sed -i "s/.*tests.*//" wscript
  $sed -i "s/.*example-clients.*//" wscript

  local options=""
  CFLAGS="-I$PREFIX/$host/include -L$PREFIX/$host/lib"
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

function jack_patches {
  local patchFile1=$scriptDir/patches/jack_01_OptionalPortAudio.diff
  cat << 'EOF' > $patchFile1
diff --git a/common/wscript b/common/wscript
index 4302b1e..c39aec1 100644
--- a/common/wscript
+++ b/common/wscript
@@ -380,7 +380,7 @@ def build(bld):
          process = create_jack_process_obj(bld, 'audioadapter', audio_adapter_sources, serverlib)
          process.use = 'SAMPLERATE'
 
-    if bld.env['BUILD_ADAPTER'] and bld.env['IS_WINDOWS']:
+    if bld.env['BUILD_ADAPTER'] and bld.env['HAVE_PORTAUDIO']:
          audio_adapter_sources += ['../windows/portaudio/JackPortAudioAdapter.cpp', '../windows/portaudio/JackPortAudioDevices.cpp']
          process = create_jack_process_obj(bld, 'audioadapter', audio_adapter_sources, serverlib)
          process.use += ['SAMPLERATE', 'PORTAUDIO']
diff --git a/windows/wscript b/windows/wscript
index ea4dd3d..f00d66e 100644
--- a/windows/wscript
+++ b/windows/wscript
@@ -2,7 +2,7 @@
 # encoding: utf-8
 
 def configure(conf):
-    conf.check_cfg(package='portaudio-2.0', uselib_store='PORTAUDIO', atleast_version='19', args='--cflags --libs')
+    conf.check_cfg(package='portaudio-2.0', uselib_store='PORTAUDIO', atleast_version='19', args='--cflags --libs', mandatory=False)
     conf.env['BUILD_DRIVER_PORTAUDIO'] = conf.is_defined('HAVE_PORTAUDIO')
 
 def create_jack_driver_obj(bld, target, sources, uselib = None):
EOF

  local patchFile2=$scriptDir/patches/jack_03_NoExamples.diff
  cat << 'EOF' > $patchFile2
diff --git a/wscript b/wscript
index aef4bd8..06cf2ba 100644
--- a/wscript
+++ b/wscript
@@ -171,7 +171,7 @@ def configure(conf):
     if conf.is_defined('HAVE_SAMPLERATE'):
         conf.env['LIB_SAMPLERATE'] = ['samplerate']
 
-    conf.sub_config('example-clients')
+    #conf.sub_config('example-clients')
 
     if conf.check_cfg(package='celt', atleast_version='0.11.0', args='--cflags --libs', mandatory=False):
         conf.define('HAVE_CELT', 1)
@@ -429,7 +429,7 @@ def build(bld):
 
     if bld.env['IS_WINDOWS']:
         bld.add_subdirs('windows')
-        bld.add_subdirs('example-clients')
+        #bld.add_subdirs('example-clients')
         #bld.add_subdirs('tests')
 
     if bld.env['BUILD_DOXYGEN_DOCS'] == True:
EOF

  local patchFile3=$scriptDir/patches/jack_04_OptionalSampleRate.diff
  cat << 'EOF' > $patchFile3
diff --git a/common/wscript b/common/wscript
index 4302b1e..53d453d 100644
--- a/common/wscript
+++ b/common/wscript
@@ -6,7 +6,7 @@ import re
 import os
 
 def configure(conf):
-    conf.check_cc(header_name='samplerate.h', define_name="HAVE_SAMPLERATE")
+    conf.check_cc(header_name='samplerate.h', define_name="HAVE_SAMPLERATE", mandatory=False)
    
     if conf.is_defined('HAVE_SAMPLERATE'):
         conf.env['LIB_SAMPLERATE'] = ['samplerate']
diff --git a/wscript b/wscript
index aef4bd8..98d76ca 100644
--- a/wscript
+++ b/wscript
@@ -166,7 +166,7 @@ def configure(conf):
         if conf.env['BUILD_JACKDBUS'] != True:
             conf.fatal('jackdbus was explicitly requested but cannot be built')
 
-    conf.check_cc(header_name='samplerate.h', define_name="HAVE_SAMPLERATE")
+    conf.check_cc(header_name='samplerate.h', define_name="HAVE_SAMPLERATE", mandatory=False)
 
     if conf.is_defined('HAVE_SAMPLERATE'):
         conf.env['LIB_SAMPLERATE'] = ['samplerate']
EOF

  applyPatch $patchFile1
  applyPatch $patchFile2
  applyPatch $patchFile3
}
