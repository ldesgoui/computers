# sniper

## creation

```sh
$ scw instance server create \
    name=sniper \
    type=DEV1-S \
    boot-type=rescue \
    root-volume=local:20GB \
    dynamic-ip-required=false \
    ip=f514ee28-7a6e-485c-8333-b5b93cc8b8f2
```

## installation

```
$ scw instance server ssh <UUID>
$ apt update && apt install -y zfsutils-linux && apt clear
$ curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
$ . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```
