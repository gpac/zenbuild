
function portaudio_build {
  host=$1
  pushd $WORK/src
  lazy_download "portaudio.tar.gz" "http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz"
  lazy_extract "portaudio.tar.gz"
  mkgit "portaudio"

  autoconf_build $host "portaudio" \
      --disable-static \
      --enable-shared

  popd
}

function portaudio_get_deps {
  local a=1;
}
