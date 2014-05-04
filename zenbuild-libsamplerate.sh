
function build_libsamplerate {
  host=$1
  pushd $WORK/src

  lazy_download "libsamplerate.tar.gz" "http://www.mega-nerd.com/SRC/libsamplerate-0.1.8.tar.gz"
  lazy_extract "libsamplerate.tar.gz"
  mkgit "libsamplerate"

  autoconf_build $host "libsamplerate" \
      --disable-static \
      --enable-shared \
      --disable-sndfile \
      --disable-fftw

  popd
}

