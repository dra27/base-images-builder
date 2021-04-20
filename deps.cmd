@setlocal
@echo off

set ISOLATION=hyperv

docker build -t builder-base --isolation=%ISOLATION% .
docker tag builder-base builder-deps

for /l %%i in (1,1,4) do (
  docker run --isolation=%ISOLATION% --cpu-count=8 --memory=8g -v %CD%:C:\cygwin64\home\opam\base-images-builder --name basic-next builder-deps C:\cygwin64\bin\bash.exe --login -c "~/base-images-builder/build.sh %%i"
  if errorlevel 1 (
    echo Step %%i failed
    docker container rm basic-next -f
    goto :EOF
  )
  docker commit basic-next builder-deps
  docker container rm basic-next -f
)
docker tag builder-deps builder

goto :EOF