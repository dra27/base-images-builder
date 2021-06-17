# base-images-builder

Build the [OCluster][ocluster] tools required to build OCaml and Opam
[Docker base images][docker-base-images].

The current Docker Hub user/repo the images are pushed to is
[`antonindecimo/opam-windows`][docker-hub] and it's a hack as I don't
use a staging user. Change it in `build.sh` and in the script below,
in `--allow-push`.

As another hack, the password for the Docker Hub user need to be
written to the usual mount points of secrets if starting base-images
directly and not through docker-compose. On Windows, that's
`C:\ProgramData\Docker\secrets\ocurrent-hub`.

Encode the cap files in UTF8 (without BOM) or ASCII, with LF line
endings for better results.

Download and extract the repo, have Docker for Windows configured to
run Windows jobs, then

``` batchfile
@rem on the worker
git config --system core.longpaths true

@rem the current repo
cd base-images-builder

@rem the OCluster state
set LIB=C:\Windows\System32\config\systemprofile\AppData\Roaming

@rem the secrets directory
set SECRETS=%CD%\capnp-secrets

@rem the Docker Hub account where to push images
set ALLOW_PUSH=antonindecimo/opam-windows

mkdir %SECRETS%

@rem Build everything
deps.cmd && build.cmd

.\output\ocluster-scheduler.exe install ^
  --capnp-secret-key-file=%SECRETS%\key.pem ^
  --capnp-listen-address=tcp:0.0.0.0:9000 ^
  --capnp-public-address=tcp:localhost:9000 ^
  --state-dir=%LIB%\ocluster-scheduler ^
  --secrets-dir=%SECRETS% ^
  --pools=windows-x86_64

@rem as an Administrator
sc start ocluster-scheduler

set /a CAPACITY=NUMBER_OF_PROCESSORS/2

.\output\ocluster-worker.exe install ^
  --state-dir=%LIB%\ocluster-worker ^
  --name=%COMPUTERNAME%-worker ^
  --capacity=%CAPACITY% ^
  --allow-push=%ALLOW_PUSH% ^
  --prune-threshold=10 ^
  --connect=%SECRETS%\pool-windows-x86_64.cap

@rem as an Administrator
sc start ocluster-worker

.\output\ocluster-admin.exe add-client ^
  --connect=%SECRETS%\admin.cap user > %SECRETS%\user.cap

.\output\base-images.exe ^
  --submission-service=%SECRETS%\user.cap ^
  --staging-password-file=C:\ProgramData\docker\secrets\ocurrent-hub
```

[ocluster]: https://github.com/ocurrent/ocluster/
[docker-base-images]: https://github.com/ocurrent/docker-base-images
[docker-hub]: https://hub.docker.com/r/antonindecimo/opam-windows
