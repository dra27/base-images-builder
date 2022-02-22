#!/usr/bin/env bash

set -ex
shopt -s nullglob

export "PATH=/usr/x86_64-w64-mingw32/bin:$PATH"

OUTPUT=/home/opam/builder/output

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
