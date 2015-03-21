#!/bin/bash
set -euo pipefail

readonly JOBS=$(nproc)
export MAKE="make -j$JOBS"

rm -f "/tmp/test-zenbuild/flags/x86_64-linux-gnu/all.built"
./zenbuild.sh "/tmp/test-zenbuild" all x86_64-linux-gnu

rm -f "/tmp/test-zenbuild/flags/x86_64-w64-mingw32/all.built"
./zenbuild.sh "/tmp/test-zenbuild" all x86_64-w64-mingw32

