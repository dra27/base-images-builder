# escape=`
FROM antonindecimo/opam-windows:windows-mingw-20H2-ocaml-4.12-amd64
RUN git clone --recursive https://github.com/MisterDA/docker-base-images.git && cd docker-base-images && git checkout b22719d76ec5322ab42292ff022e7c4760f842a0 && git submodule update --recursive
ADD https://capnproto.org/capnproto-c++-win32-0.8.0.zip capnproto-c++-win32-0.8.0.zip
RUN C:\cygwin64\bin\bash.exe --login -c "unzip capnproto-c++-win32-0.8.0.zip && mv capnproto-tools-win32-0.8.0/* /usr/bin"
RUN C:\cygwin64\bin\bash.exe --login -c "mv /etc/postinstall/zp_cygsympathy.sh /etc/postinstall/zp_zcygsympathy.sh"
RUN ocaml-env exec -- opam depext -y conf-gmp conf-graphviz conf-sqlite3
RUN ocaml-env exec -- opam depext -yi conf-gmp conf-graphviz conf-sqlite3
ENV CYGWIN=winsymlinks:nativestrict
RUN opam config set-global jobs 63
ADD build.sh .
