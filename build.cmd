@setlocal
@echo off

set ISOLATION=hyperv

if exist output rd /s/q output
md output

docker container rm builder-run >nul 2>&1
docker run --isolation=%ISOLATION% --name builder-run --cpu-count=8 --memory=8g -it -v %CD%\output:C:\output builder C:\cygwin64\bin\bash.exe --login -c "~/build.sh extract"
docker commit builder-run builder

goto :EOF