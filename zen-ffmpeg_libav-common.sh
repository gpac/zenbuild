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

function checkForCommonBuildTools {
  if isMissing "pkg-config"; then
    echo "pkg-config not installed.  Please install with:"
    echo "pacman -S pkgconfig"
    echo "or"
    echo "apt-get install pkg-config"
    exit 1
  fi

  if isMissing "patch"; then
    echo "patch not installed.  Please install with:"
    echo "pacman -S patch"
    echo "or"
    echo "apt-get install patch"
    exit 1
  fi

  if isMissing "python2"; then
    echo "python2 not installed.  Please install with:"
    echo "pacman -S python2"
    echo "or"
    echo "apt-get install python2"
    exit 1
  fi

  if isMissing "autoreconf"; then
    echo "autoreconf not installed."
    exit 1
  fi

  if isMissing "libtool"; then
    echo "libtool not installed.  Please install with:"
    echo "pacman -S msys/libtool"
    echo "or"
    echo "apt-get install libtool"
    exit 1
  fi

  if isMissing "make"; then
    echo "make not installed.  Please install with:"
    echo "pacman -S make"
    echo "or"
    echo "apt-get install make"
    exit 1
  fi

  if isMissing "autopoint"; then
    echo "autopoint not installed.  Please install with:"
    echo "pacman -S gettext gettext-devel"
    echo "or"
    echo "apt-get install autopoint"
    exit 1
  fi

  if isMissing "yasm"; then
    echo "yasm not installed.  Please install with:"
    echo "apt-get install yasm"
    exit 1
  fi

  if isMissing "wget"; then
    echo "wget not installed.  Please install with:"
    echo "pacman -S msys/wget"
    echo "or"
    echo "apt-get install wget"
    exit 1
  fi

  if isMissing "sed"; then
    echo "sed not installed.  Please install with:"
    echo "pacman -S msys/sed"
    echo "or"
    echo "apt-get install sed"
    exit 1
  fi

  if isMissing "tar"; then
    echo "tar not installed.  Please install with:"
    echo "mingw-get install tar"
    echo "or"
    echo "apt-get install tar"
    exit 1
  fi

  if isMissing "git" ; then
    echo "git not installed.  Please install with:"
    echo "pacman -S mingw-git"
    echo "or"
    echo "apt-get install git"
    exit 1
  fi
}

function get_arch {
  host=$1
  echo $host | sed "s/-.*//"
}

function get_os {
  host=$1
  echo $host | sed "s/.*-//"
}

checkForCommonBuildTools


