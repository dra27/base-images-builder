#!/usr/bin/env bash

set -ex
shopt -s nullglob

export "PATH=/usr/x86_64-w64-mingw32/bin:$PATH"

case $1 in
1)
  ocaml-env exec -- opam source mirage-crypto.0.10.5
  cd mirage-crypto.0.10.5
  ocaml-env exec -- opam install -y --deps-only --with-test ./mirage-crypto.opam
  PKG_CONFIG_PATH=$(cygpath -u "$(ocaml-env exec -- opam var lib)")/pkgconfig
  ocaml-env exec -- env PKG_CONFIG_PATH="$PKG_CONFIG_PATH" dune build -p mirage-crypto @install
  ocaml-env exec -- env PKG_CONFIG_PATH="$PKG_CONFIG_PATH" opam install -y ./mirage-crypto.opam
  ocaml-env exec -- opam install -y --deps-only --with-test ./mirage-crypto-ec.opam
  ocaml-env exec -- env PKG_CONFIG_PATH="$PKG_CONFIG_PATH" dune build -p mirage-crypto-ec @install
  ocaml-env exec -- env PKG_CONFIG_PATH="$PKG_CONFIG_PATH" opam install -y ./mirage-crypto-ec.opam
;;
2)
  cd ocluster || exit
  git fetch MisterDA
  git switch windows
  ocaml-env exec -- opam install -y --deps-only .
  git submodule update --recursive

  cd obuilder || exit
  ocaml-env exec -- opam install -y --deps-only .
  cd ../.. || exit
;;
extract)
  PROFILE=debug

  cd ocluster || exit
  mkdir -p install
  ocaml-env exec -- dune build @install --profile=$PROFILE --root=.
  ocaml-env exec -- dune install --prefix=install --relocatable --root=.

  OUTPUT=/home/opam/base-images-builder/output

  cd .. || exit
  for dir in ocluster/install/bin; do
    for exe in "$dir"/*.exe ; do
      for dll in $(PATH="/usr/x86_64-w64-mingw32/sys-root/mingw/bin:$PATH" cygcheck "$exe" | grep -F x86_64-w64-mingw32 | sed -e 's/^ *//'); do
        if [ ! -e "$OUTPUT/$(basename "$dll")" ] ; then
          echo "Extracting $dll for $exe"
          cp "$dll" "$OUTPUT/"
        else
        echo "$exe uses $dll (already extracted)"
        fi
      done
      echo "Extracted $exe"
      cp "$exe" "$OUTPUT/"
    done
  done
;;
esac
