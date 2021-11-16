@setlocal
@echo off

set /a CPU_COUNT=%NUMBER_OF_PROCESSORS%/2

if exist output rd /s/q output
md output

docker container rm builder-run >nul 2>&1
docker run --isolation=%ISOLATION% --cpu-count=%CPU_COUNT% --memory=8g ^
           --network="%NETWORK%" --user=ContainerAdministrator ^
           --name builder-run ^
           -v %CD%:C:\cygwin64\home\opam\base-images-builder ^
           --entrypoint C:\cygwin64\bin\bash.exe ^
           -t builder --login -c "~/base-images-builder/build.sh extract"
docker commit builder-run builder

goto :EOF
