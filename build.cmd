@setlocal
@echo off

set ISOLATION=hyperv
set /a CPU_COUNT=NUMBER_OF_PROCESSORS/2

if exist output rd /s/q output
md output

docker container rm builder-run >nul 2>&1
docker run --isolation=%ISOLATION% --name builder-run --cpu-count=%CPU_COUNT% --memory=8g -it -v %CD%:C:\cygwin64\home\opam\base-images-builder -v %CD%\output:C:\output builder C:\cygwin64\bin\bash.exe --login -c "~/base-images-builder/build.sh extract"
docker commit builder-run builder

goto :EOF
