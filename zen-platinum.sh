

function platinum_build {

  set -x

  local host=$1
  pushDir $WORK/src

  lazy_git_clone https://github.com/gpac-buildbot/PlatinumSDK.git platinum mingw

  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)

  local PLAT_TARGET="x86-unknown-linux"
  case $OS in
    mingw*)
      PLAT_TARGET="x86-win32-mingw"
      ;;
    darwin|osx|macos)
      PLAT_TARGET="universal-apple-macosx"
      ;;
  esac

  pushDir platinum
  pushDir Platinum

  scons target=$PLAT_TARGET cross_prefix=$host install_dir=$PREFIX/$host/lib

  for lib in Targets/$PLAT_TARGET/Debug/*.a
  do
    ${cross_prefix}ranlib $lib
  done
  cp -av Targets/$PLAT_TARGET/Debug/* $PREFIX/$host/lib/

  popDir
  popDir
  popDir

  set +x

}


function platinum_get_deps {
 local a=0
}
