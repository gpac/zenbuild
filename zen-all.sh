
# Copyright (C) 2015 - Sebastien Alaiwan
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

function all_build {
  echo "Done"
}

function all_get_deps {
# echo "dbus"
  echo "expat"
# echo "faad2" # error: "two or more data types in declaration specifiers"
# echo "ffmpeg"
  echo "fontconfig"
  echo "freetype2"
  echo "fribidi"
  echo "gmplib"
# echo "gnutls"
# #echo "gpac" requires ffmpeg -fPIC
# echo "jack"
  echo "liba52"
# echo "libalsa"
  echo "libass"
# echo "libav"
  echo "libfdk-aac"
  echo "libgcrypt"
  echo "libgpg-error"
  echo "libjpeg"
  echo "libmad"
  echo "libnettle"
  echo "libogg"
  echo "libopenjpeg"
  echo "libpng"
# echo "libpthread"
  echo "librtmp"
  echo "libsamplerate"
  echo "libsdl"
  echo "libsndfile"
  echo "libtheora"
  echo "libvorbis"
  echo "libvpx"
# echo "libxau"
# echo "libxcb"
# echo "libxvidcore"
  echo "opencore-amr"
  echo "openh264"
# echo "openhevc"
  echo "opus"
  echo "portaudio"
# #echo "pthreads" can only be built for windows
  echo "sodium"
  echo "toxcore"
  echo "tre"
# #echo "utox" depends on xrender and other missing stuff, causing pkg-config to return nothing
# #echo "vlc" requires ffmpeg -fPIC
  echo "x264"
  echo "x265"
# echo "xcb-proto"
# echo "xcbproto"
# echo "xcbpthreadstubs"
# echo "xproto"
  echo "zlib"
}

