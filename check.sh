#!/bin/bash
set -euo pipefail

readonly JOBS=$(nproc)
export MAKE="make -j$JOBS"

./zenbuild.sh "/tmp/test-zenbuild-$$" all x86_64-linux-gnu
./zenbuild.sh "/tmp/test-zenbuild-$$" all x86_64-w64-mingw32

