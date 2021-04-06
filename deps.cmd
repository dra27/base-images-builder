@setlocal
@echo off

set ISOLATION=hyperv

docker build -t builder-base --isolation=%ISOLATION% .

docker tag builder-base builder-deps
docker container rm basic-next -f

for /l %%i in (1,1,3) do (
  docker run --isolation=%ISOLATION% --cpu-count=8 --memory=8g --name basic-next builder-image C:\cygwin64\bin\bash.exe --login -c "~/build.sh %%i"
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

