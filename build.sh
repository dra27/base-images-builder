#!/usr/bin/env bash

case $1 in
1)
  cd docker-base-images
  ocaml-env exec -- opam install -y --deps-only --with-test .
;;
2)
  cd docker-base-images/ocluster
  ocaml-env exec -- opam install -y --deps-only --with-test .
;;
3)
  cd docker-base-images/ocurrent
  ocaml-env exec -- opam install -y --deps-only --with-test .
;;
4)
  cd docker-base-images
  mkdir install
  ocaml-env exec -- dune build @install --profile=release
  ocaml-env exec -- dune install --prefix=install --relocatable
;;
5)
  cd docker-base-images/ocluster
  mkdir install
  ocaml-env exec -- dune build @install --profile=release --root=.
  ocaml-env exec -- dune install --prefix=install --relocatable --root=.
;;
extract)
  for dir in docker-base-images/install/bin docker-base-images/ocluster/install/bin; do
    for exe in $dir/*.exe ; do
      for dll in $(PATH="/usr/x86_64-w64-mingw32/sys-root/mingw/bin:$PATH" cygcheck "$exe" | fgrep x86_64-w64-mingw32 | sed -e 's/^ *//'); do
        if [ ! -e /cygdrive/c/output/$(basename "$dll") ] ; then
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
