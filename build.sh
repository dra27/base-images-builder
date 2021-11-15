#!/usr/bin/env bash

set -ex
shopt -s nullglob

export "PATH=/usr/x86_64-w64-mingw32/bin:$PATH"

case $1 in
1)
  ocaml-env exec -- opam source mirage-crypto.0.10.4
  cd mirage-crypto.0.10.4
  ocaml-env exec -- opam install -y --deps-only --with-test ./mirage-crypto.opam
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.13/lib/pkgconfig dune build -p mirage-crypto @install
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.13/lib/pkgconfig opam install -y ./mirage-crypto.opam
  ocaml-env exec -- opam install -y --deps-only --with-test ./mirage-crypto-ec.opam
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.13/lib/pkgconfig dune build -p mirage-crypto-ec @install
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.13/lib/pkgconfig opam install -y ./mirage-crypto-ec.opam

  cd ../docker-base-images/ocurrent
  ocaml-env exec -- opam install -y --deps-only .
;;
2)
  cd ocluster
  ocaml-env exec -- opam install -y --deps-only .
;;
3)
  cd docker-base-images
  ocaml-env exec -- opam install -y --deps-only .
;;
extract)
  PROFILE=debug

  rm -rf docker-base-images ocluster
  git clone --recursive --depth=1 https://github.com/ocurrent/docker-base-images.git
  git clone --recursive --depth=1 https://github.com/ocurrent/ocluster.git

  cd ocluster || exit
  mkdir -p install
  ocaml-env exec -- dune build @install --profile=$PROFILE --root=.
  ocaml-env exec -- dune install --prefix=install --relocatable --root=.

  mkdir -p install
  ocaml-env exec -- dune build @install --profile=$PROFILE
  ocaml-env exec -- dune install --prefix=install --relocatable

  cd .. || exit
  for dir in docker-base-images/install/bin ocluster/install/bin; do
    for exe in "$dir"/*.exe ; do
      for dll in $(PATH="/usr/x86_64-w64-mingw32/sys-root/mingw/bin:$PATH" cygcheck "$exe" | grep -F x86_64-w64-mingw32 | sed -e 's/^ *//'); do
        if [ ! -e "/cygdrive/c/output/$(basename "$dll")" ] ; then
          echo "Extracting $dll for $exe"
          cp "$dll" /cygdrive/c/output/
        else
        echo "$exe uses $dll (already extracted)"
        fi
      done
      echo "Extracted $exe"
      cp "$exe" /cygdrive/c/output/
    done
  done
;;
esac
