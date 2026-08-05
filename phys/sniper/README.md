# sniper

## creation

```sh
$ scw instance server create \
    name=sniper \
    type=DEV1-S \
    boot-type=rescue \
    root-volume=local:20GB \
    additional-volumes.0=block:10GB \
    dynamic-ip-required=false \
    ip=f514ee28-7a6e-485c-8333-b5b93cc8b8f2
```

## installation

```
$ scw instance server ssh <UUID>
$ apt update && apt install -y zfsutils-linux
$ mkfs.ext4 /dev/sda
$ mkdir /nix
$ mount /dev/sda /nix
$ fallocate -l 2G /nix/swap
$ mkswap /nix/swap
$ swapon /nix/swap
$ curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes --no-confirm
$ . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
$ nix shell github:ldesgoui/computers#disko
$ disko-install --flake github:ldesgoui/computers#sniper --disk nvme /dev/vda --write-efi-boot-entries
$ cat /tmp/oh-god-dont-leak/sniper.passphrase # Back this up
$ zfs set keylocation=prompt harvest/sniper
```
