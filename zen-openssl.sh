

function openssl_build {

  set -x

  local host=$1
  pushDir $WORK/src

  lazy_git_clone git://git.openssl.org/openssl.git openssl OpenSSL_1_1_0h

  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)


  pushDir openssl

  /usr/bin/perl Configure --prefix=$PREFIX/$host no-idea no-mdc2 no-rc5 no-makedepend shared mingw64 --cross-compile-prefix=$host-
  make
  make install


  set +x

  popDir
  popDir
}


function openssl_get_deps {
 local a=0
}
