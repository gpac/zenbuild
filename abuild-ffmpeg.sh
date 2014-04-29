#!/bin/bash

source abuild.sh

BUILD=$($scriptDir/config.guess | sed 's/-unknown-msys$/-pc-mingw32/')
HOST=$BUILD
printMsg "Build type: $BUILD"

export CFLAGS="-O2"
export CXXFLAGS="-O2"
export LDFLAGS="-s"

installErrorHandler

export GCC_PREFIX="$WORK/gdc-4.8/release"


CACHE=$WORK/cache
mkdir -p $WORK/gdc-4.8/src
mkdir -p $CACHE

if [ -z "$MAKE" ]; then
  MAKE="make"
fi

export MAKE

if isMissing "wget"; then
  echo "wget not installed.  Please install with:"
  echo "pacman -S msys-wget"
  echo "or"
  echo "apt-get install wget"
  exit 1
fi

if isMissing "unzip"; then
  echo "unzip not installed.  Please install with:"
  echo "pacman -S msys/unzip"
  echo "or"
  echo "apt-get install unzip"
  exit 1
fi

if isMissing "tar"; then
  echo "tar not installed.  Please install with:"
  echo "mingw-get install tar"
  echo "or"
  echo "apt-get install tar"
  exit 1
fi

if isMissing "patch"; then
  echo "patch not installed.  Please install with:"
  echo "mingw-get install patch"
  echo "or"
  echo "apt-get install patch"
  exit 1
fi

if isMissing "gcc" ; then
  echo "gcc not installed.  Please install with:"
  echo "pacman -S mingw-gcc"
  echo "or"
  echo "apt-get install gcc"
  exit 1
fi

if isMissing "git" ; then
  echo "git not installed.  Please install with:"
  echo "pacman -S mingw-git"
  echo "or"
  echo "apt-get install git"
  exit 1
fi


pushd $WORK/gdc-4.8/src

# Download and install x86-64 build tools

function build_runtime
{
  lazy_download "$CACHE/mingw-w64-v3.0.0.tar.bz2" "http://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-v3.0.0.tar.bz2/download"
  lazy_extract "mingw-w64-v3.0.0.tar.bz2"
  mkgit "mingw-w64-v3.0.0"

  pushd mingw-w64-v3.0.0

  printMsg "********************************************************************************"
  printMsg "Building runtime headers"
  pushd mingw-w64-headers
  mkdir -p build
  cd build
  if [ ! -e .built ] ; then
    ../configure \
      --prefix=$WORK/gdc-4.8/release/x86_64-$vendor-mingw32 \
      --build=$BUILD \
      --host=x86_64-$vendor-mingw32
    $MAKE
    $MAKE install
    touch .built
  fi
  popd

  printMsg "********************************************************************************"
  printMsg "Building runtime CRT"
  pushd mingw-w64-crt
  mkdir -p build
  cd build
  if [ ! -e .built ] ; then
    ../configure \
      --prefix=$WORK/gdc-4.8/release/x86_64-$vendor-mingw32 \
      --build=$BUILD \
      --host=x86_64-$vendor-mingw32
    $MAKE && $MAKE install
    touch .built
  fi
  popd

  printMsg "********************************************************************************"
  printMsg "Building pthreads"
  pushd mingw-w64-libraries/winpthreads
  mkdir -p build
  cd build
  if [ ! -e .built ] ; then
    ../configure \
      --prefix=$WORK/gdc-4.8/release/x86_64-$vendor-mingw32 \
      --build=$BUILD \
      --host=x86_64-$vendor-mingw32
    $MAKE
    $MAKE install
    touch .built
  fi
  popd

  popd
}

# Compile GMP
if [ ! -e gmp-5.1.3/build/.built ]; then

  printMsg "********************************************************************************"
  printMsg "Building GMP"

  lazy_download "$CACHE/gmp-5.1.3.tar.bz2" "http://ftp.gnu.org/gnu/gmp/gmp-5.1.3.tar.bz2"
  lazy_extract "gmp-5.1.3.tar.bz2"
  mkgit "gmp-5.1.3"

  pushd gmp-5.1.3

  # Make 64
  mkdir -p build/64
  cd build/64
  ../../configure \
    --prefix=$WORK/gdc-4.8/gmp-5.1.3/64 \
    --build=$BUILD \
    --host=$HOST \
    --enable-cxx \
    --enable-static \
    --disable-shared \
    ABI=64
  $MAKE && $MAKE install
  cd ..
  touch .built
  popd
fi

# Compile MPFR
if [ ! -e mpfr-3.1.1/build/.built ]; then

  printMsg "********************************************************************************"
  printMsg "Building MPFR"

  lazy_download "$CACHE/mpfr-3.1.1.tar.bz2" "http://ftp.gnu.org/gnu/mpfr/mpfr-3.1.1.tar.bz2"
  lazy_extract "mpfr-3.1.1.tar.bz2"
  mkgit "mpfr-3.1.1"

  pushd mpfr-3.1.1

  # Make 64
  mkdir -p build/64
  pushd build/64
  ../../configure \
    --prefix=$WORK/gdc-4.8/mpfr-3.1.1/64 \
    --build=$BUILD \
    --host=$HOST \
    --disable-static \
    --with-gmp=$WORK/gdc-4.8/gmp-5.1.3/64 \
    --enable-static \
    --disable-shared
  $MAKE
  $MAKE install
  popd

  touch build/.built
  popd
fi

# Copy runtime files to release
mkdir -p $GCC_PREFIX/x86_64-$vendor-mingw32
mkdir -p $GCC_PREFIX/x86_64-$vendor-mingw32/bin32
mkdir -p $GCC_PREFIX/x86_64-$vendor-mingw32/lib32

#cp -Rp $GCC_PREFIX/x86_64-$vendor-mingw32/bin/*.dll $GCC_PREFIX/bin

function download_gdc {

  if [ ! -d "$CACHE/GDC" ]; then
    git clone https://github.com/Ace17/GDC.git "$CACHE/GDC" -b $GDC_BRANCH
  fi

  rm -rf GDC
  git clone "$CACHE/GDC" -b $GDC_BRANCH

  pushd GDC

  if [ "$GDC_VERSION" != "" ]; then
    git checkout $GDC_VERSION
  fi

  popd
}

function download_gcc {

  lazy_download "$CACHE/gcc-4.8.2.tar.bz2" "http://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2"
  lazy_extract "gcc-4.8.2.tar.bz2"
  mkgit "gcc-4.8.2"
}

# Setup GDC and compile
function build_gdc_host {

  if [ -e gcc-4.8.2/build/.built ] ; then
    return 0
  fi

  download_gdc
  download_gcc

  pushd GDC
  ./setup-gcc.sh ../gcc-4.8.2
  popd

  pushd gcc-4.8.2
  applyPatch "$scriptDir/patches/mingw-tls-gcc-4.8.patch"
  applyPatch "$scriptDir/patches/gcc/0001-Remove-fPIC-for-MinGW.patch"

  # Build GCC
  mkdir -p build
  cd build

  # Must build GCC using patched mingwrt
  export LPATH="$GCC_PREFIX/lib;$GCC_PREFIX/x86_64-$vendor-mingw32/lib"
  export CPATH="$GCC_PREFIX/include;$GCC_PREFIX/x86_64-$vendor-mingw32/include"
  #export BOOT_CFLAGS="-static-libgcc -static"
  ../configure \
    --prefix=$GCC_PREFIX \
    --build=$BUILD \
    --host=$HOST \
    --with-local-prefix=$GCC_PREFIX \
    --target=x86_64-$vendor-mingw32 \
    --enable-languages=c,c++,d,lto \
    --with-gmp=$WORK/gdc-4.8/gmp-5.1.3/64 \
    --with-mpfr=$WORK/gdc-4.8/mpfr-3.1.1/64 \
    --with-mpc=$WORK/gdc-4.8/mpc-1.0.1/64 \
    --enable-sjlj-exceptions \
    --enable-lto \
    --disable-nls \
    --disable-multilib \
    --disable-win32-registry \
    --with-gnu-ld \
    --disable-bootstrap
  $MAKE all-host
  $MAKE install-host
  touch .built
  popd
}

function build_gdc_target {
  pushd gcc-4.8.2/build
  $MAKE all-target
  $MAKE install-target
  popd
}

build_gdc_host
build_runtime
build_gdc_target

uninstallErrorHandler
exit 0


# get DMD script
if [ ! -d "GDMD" ]; then
  git clone https://github.com/D-Programming-GDC/GDMD.git
else
  cd GDMD
  git pull
  cd ..
fi
pushd GDMD
#Ok to fail. results in testsuite not running
PATH=/c/strawberry/perl/bin:$PATH TMPDIR=. cmd /c "pp dmd-script -o gdmd.exe"
cp gdmd.exe $WORK/gdc-4.8/release/bin/
cp dmd-script $WORK/gdc-4.8/release/bin/gdmd
popd

# Test build
# Run unitests via check-d
# Verify gdmd exists.
# test commands need to avoid exit on error
echo -n "Checking for gdmd.exe..."
gdmd=$(which gdmd.exe 2>/dev/null)
if [ ! "$gdmd" ]; then
  echo "Unable to run DMD testsuite. gdmd.exe failed to compile"
  exit 1
fi

# Run testsuite via dmd
echo "dmd cloning"
if [ ! -d "dmd" ]; then
  git clone https://github.com/D-Programming-Language/dmd.git -b 2.062
else
  cd dmd
  git reset --hard
  git clean -f
  git pull
  # Reset RPO
  cd ..
fi
pushd dmd/test
patch -p2 < $scriptDir/patches/mingw-testsuite.patch
$MAKE
pushd

