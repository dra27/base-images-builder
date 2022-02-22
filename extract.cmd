@setlocal
@echo off

if exist output rd /s/q output
md output

docker build -f Dockerfile.build -t ocluster-worker .
docker run --name ocluster-work-slurp --rm ^
           -v %CD%:C:\cygwin64\home\opam\builder ^
           --entrypoint C:\cygwin64\bin\bash.exe ^
           -t ocluster-worker --login -c "~/builder/extract.sh"
