

function js_build {

  set -x

  local host=$1
  pushDir $WORK/src

  lazy_git_clone https://github.com/gpac-buildbot/js.git js master


  local OS=$(get_os $host)

  local ext=ref
  case $OS in
    mingw*)
      ext=mingw
      ;;
  esac

  pushDir js

  CROSS_PREFIX="$host" make -f Makefile.$ext Linux_All_DBG.OBJ/libjs.a
  cp -av Linux_All_DBG.OBJ/libjs.a $PREFIX/$host/lib/

  set +x
  popDir
  popDir
}


function js_get_deps {
 local a=0
}
