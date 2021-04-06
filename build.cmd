@setlocal
@echo off

if exist output rd /s/q output
md output

docker build -t builder-base .

docker tag builder-base builder-image
docker container rm basic-next -f
for /l %%i in (1,1,5) do (
  docker run --cpu-count=64 --memory=48g --name basic-next builder-image C:\cygwin64\bin\bash.exe --login -c "~/build.sh %%i"
  if errorlevel 1 (
    echo Step %%i failed
    docker container rm basic-next -f
    goto :EOF
  )
  docker commit basic-next builder-image
  docker container rm basic-next -f
)

docker run --rm -it -v %CD%\output:C:\output builder-image C:\cygwin64\bin\bash.exe --login -c "~/build.sh extract"

goto :EOF

