# escape=`
FROM ocaml/opam:windows-mingw-20H2-ocaml-4.13
ADD https://capnproto.org/capnproto-c++-win32-0.9.1.zip capnproto-c++-win32-0.9.1.zip
RUN C:\cygwin64\bin\bash.exe --login -c "unzip capnproto-c++-win32-0.9.1.zip && mv capnproto-tools-win32-0.9.1/* /usr/bin"
RUN ocaml-env exec -- opam depext -yi conf-gmp conf-graphviz conf-sqlite3 conf-libffi
RUN git clone --recursive https://github.com/ocurrent/docker-base-images.git
RUN git clone --recursive https://github.com/ocurrent/ocluster.git
RUN set /a "JOBS=%NUMBER_OF_PROCESSORS%/2-1" && opam config set-global jobs %JOBS%
