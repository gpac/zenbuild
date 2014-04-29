#!/bin/bash
set -e

function printMsg
{
  echo -n "[32m"
  echo $*
  echo -n "[0m"
}

function isMissing
{
  progName=$1
  echo -n "Checking for $progName ... "
  if which $progName 1>/dev/null 2>/dev/null; then
    echo "ok"
    return 1
  else
    return 0
  fi
}

function installErrorHandler
{
  trap "printMsg 'Spawning a rescue shell in current build directory'; bash" EXIT
}

function uninstallErrorHandler
{
  trap - EXIT
}

function lazy_download
{
  local file="$1"
  local url="$2"

  if [ ! -e "$file" ]; then
    wget "$url" -c -O "${file}.tmp"
    mv "${file}.tmp" "$file"
  fi
}

function lazy_extract
{
  local archive="$1"
  echo -n "Extracting $archive ... "
  local name=$(basename $archive .tar.gz)
  name=$(basename $name .tar.bz2)

  if [ -d $name ]; then
    echo "already extracted"
  else
    rm -rf ${name}.tmp
    mkdir ${name}.tmp
    tar -C ${name}.tmp -xlf "$CACHE/$archive"  --strip-components=1
    mv ${name}.tmp $name
    echo "ok"
  fi
}

# Create or restore a directory content
function mkgit {
  dir="$1"

  pushd "$dir"
  if [ -d ".git" ]; then
    printMsg "Restoring $dir from git restore point"
    git reset --hard
    git clean -f
  else
    printMsg "Creating git for $dir"
    # prune unnecessary folders.
    git init
    git config user.email "nobody@localhost"
    git config user.name "Nobody"
    git config core.autocrlf false
    git add -f *
    git commit -m "MinGW/GDC restore point"
  fi
  popd
}

scriptDir=$(pwd)

if echo $PATH | grep " " ; then
  echo "Your PATH contain spaces, this may cause build issues."
  echo "Please clean up your PATH and retry."
  exit 3
fi

function applyPatch {
  patchFile=$1
  printMsg "Patching $patchFile"
  patch  --no-backup-if-mismatch --merge -p1 -i $patchFile
}

WORK=$1

if [ -z "$WORK" ] ; then
	echo "Usage: $0 <prefix>"
  exit 1
fi

printMsg "Building in: $WORK"

