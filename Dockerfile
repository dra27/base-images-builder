# escape=`
FROM antonindecimo/opam-windows:windows-mingw-20H2-ocaml-4.12-amd64
ADD https://capnproto.org/capnproto-c++-win32-0.8.0.zip capnproto-c++-win32-0.8.0.zip
RUN C:\cygwin64\bin\bash.exe --login -c "unzip capnproto-c++-win32-0.8.0.zip && mv capnproto-tools-win32-0.8.0/* /usr/bin"
RUN ocaml-env exec -- opam depext -yi conf-gmp conf-graphviz conf-sqlite3 conf-libffi
RUN git clone --recursive https://github.com/MisterDA/docker-base-images.git && cd docker-base-images && git submodule update --recursive
RUN opam config set-global jobs 7
