@setlocal
@echo off

set /a CPU_COUNT=%NUMBER_OF_PROCESSORS%/2
set /a OPAMJOBS=%CPU_COUNT%-1

docker build -t builder-base --isolation=%ISOLATION% --network="%NETWORK%" ^
             --build-arg OPAMJOBS .
docker tag builder-base builder-deps

for /l %%i in (1,1,3) do (
  docker run --isolation=%ISOLATION% --cpu-count=%CPU_COUNT% --memory=8g ^
             --network="%NETWORK%" --user=ContainerAdministrator ^
             --name basic-next ^
             -v %CD%:C:\cygwin64\home\opam\base-images-builder ^
             --entrypoint C:\cygwin64\bin\bash.exe ^
             builder-deps --login -c "~/base-images-builder/build.sh %%i"
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
