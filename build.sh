#!/usr/bin/env bash

set -ex
shopt -s nullglob

export "PATH=/usr/x86_64-w64-mingw32/bin:$PATH"

case $1 in
1)
  ocaml-env exec -- opam source mirage-crypto.0.10.2
  cd mirage-crypto.0.10.2
  ocaml-env exec -- opam install -y --deps-only --with-test ./mirage-crypto.opam
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.12/lib/pkgconfig dune build -p mirage-crypto @install
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.12/lib/pkgconfig opam install -y ./mirage-crypto.opam
  ocaml-env exec -- opam install -y --deps-only --with-test ./mirage-crypto-ec.opam
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.12/lib/pkgconfig dune build -p mirage-crypto-ec @install
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.12/lib/pkgconfig opam install -y ./mirage-crypto-ec.opam

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
  git clone --recursive --depth=1 --branch=windows https://github.com/MisterDA/docker-base-images.git
  git clone --recursive --depth=1 --branch=windows https://github.com/MisterDA/ocluster.git

  cd ocluster || exit
  mkdir -p install
  ocaml-env exec -- dune build @install --profile=$PROFILE --root=.
  ocaml-env exec -- dune install --prefix=install --relocatable --root=.

  cd ../docker-base-images || exit
  patch -Np1 << 'EOF'
diff --git a/src/base_images.ml b/src/base_images.ml
index 32a64ea..e951894 100644
--- a/src/base_images.ml
+++ b/src/base_images.ml
@@ -9,7 +9,7 @@ let () = Prometheus_unix.Logging.init ()

 (* A low-security Docker Hub user used to push images to the staging area.
    Low-security because we never rely on the tags in this repository, just the hashes. *)
-let staging_user = "ocurrentbuilder"
+let staging_user = "antonindecimo"

 let read_first_line path =
   let ch = open_in path in
diff --git a/src/conf.ml b/src/conf.ml
index e197878..10de546 100644
--- a/src/conf.ml
+++ b/src/conf.ml
@@ -1,7 +1,7 @@
 (* For staging arch-specific builds before creating the manifest. *)
-let staging_repo = "ocurrent/opam-staging"
+let staging_repo = "antonindecimo/opam-windows"

-let public_repo = "ocaml/opam"
+let public_repo = "antonindecimo/opam-windows"

 let password_path =
   let open Fpath in
@@ -22,7 +22,7 @@ let auth =
     let len = in_channel_length ch in
     let password = really_input_string ch len |> String.trim in
     close_in ch;
-    Some ("ocurrent", password)
+    Some ("antonindecimo", password)
   ) else (
     Fmt.pr "Password file %S not found; images will not be pushed to hub@." password_path;
     None
@@ -56,7 +56,7 @@ let switches ~arch ~distro =
 (* We can't get the active distros directly, but assume x86_64 is a superset of everything else. *)
 let distros = Dockerfile_distro.(active_distros `X86_64 |> List.filter (fun d ->
   match os_family_of_distro d with
-  | `Linux | `Windows -> true
+  | `Linux -> false | `Windows -> true
   | _ -> false))

 let arches_for ~distro = Dockerfile_distro.distro_arches Ocaml_version.Releases.latest distro
EOF

  mkdir -p install
  ocaml-env exec -- dune build @install --profile=$PROFILE
  ocaml-env exec -- dune install --prefix=install --relocatable

  cd .. || exit
  for dir in docker-base-images/install/bin ocluster/install/bin; do
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
