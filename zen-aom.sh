

function aom_build {

  set -x

  local host=$1
  pushDir $WORK/src

  lazy_git_clone https://aomedia.googlesource.com/aom aom master

  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)

  #TODO: better matching between $host and the toolchains at https://aomedia.googlesource.com/aom/+/refs/heads/master/build/cmake/toolchains
  local os=$OS
  case $OS in
    mingw*)
      os="mingw-gcc"
      ;;
  esac

  local arch=$ARCH
  case $ARCH in
    i*86)
      arch="x86"
      ;;
  esac

  local cmakefile="$arch-$os.cmake"

  mkdir -p aom/build/$host
  pushDir aom/build/$host

  CFLAGS="-I $WORK/src/aom/build/$host -I $WORK/src/aom" cmake -G "MSYS Makefiles" -Wno-dev ../.. \
          -DCMAKE_TOOLCHAIN_FILE=../../build/cmake/toolchains/$cmakefile \
          -DCMAKE_INSTALL_PREFIX=$PREFIX/$host \
          -DENABLE_DOCS=0 -DENABLE_DOCS=0 -DENABLE_EXAMPLES=0 -DENABLE_TESTDATA=0 -DENABLE_TESTS=0 -DENABLE_TOOLS=0
  make
  make install


  set +x
  popDir
  popDir
}


function aom_get_deps {
 local a=0
}
