
build_pthreads() {
  host=$1
  pushd $WORK/src

  lazy_download "mingw-w64.tar.bz2" "http://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-v3.1.0.tar.bz2/download"
  lazy_extract "mingw-w64.tar.bz2"

  pushd mingw-w64/mingw-w64-libraries
  autoconf_build $host "winpthreads"
  popd

  popd
}

