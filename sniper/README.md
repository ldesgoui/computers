# sniper

## Installation

```
$ scw instance server create \
    name=sniper \
    type=DEV1-S \
    boot-type=rescue \
    root-volume=local:20GB \
    additional-volumes.0=block:1GB \
    additional-volumes.1=block:4GB \
    additional-volumes.2=block:10GB \
    additional-volumes.3=block:5GB \
    dynamic-ip-required=false \
    ip=f514ee28-7a6e-485c-8333-b5b93cc8b8f2 \
    security-group-id=d5f72a58-6668-492f-ba72-0eae7693cc4b
$ ssh root@sniper.wi.lde.sg
$ fdisk -l
# commit changes to sniper/storage.os.nix
$ mkfs.ext4 /dev/sd<5GB>
$ mkdir /nix
$ mount /dev/sd<5GB> /nix
$ mkfs.fat -F 32 /dev/sda
$ mkswap /dev/sdb
$ swapon /dev/sdb
$ curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
      sh -s -- install --no-confirm
$ . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
$ apt install -y zfsutils-linux
$ nix run github:ldesgoui/computers#nixosConfigurations.sniper.config.system.build.zfsCreatePools
$ nix run github:ldesgoui/computers#nixosConfigurations.sniper.config.system.build.zfsCreateDatasets
$ mount.zfs main/enc/sys/root /mnt
$ mkdir -p /mnt/nix /mnt/boot /mnt/home/ldesgoui
$ mount.zfs main/clr/sys/nix /mnt/nix
$ mount -o umask=077 /dev/sda /mnt/boot
$ mount.zfs main/enc/users/ldesgoui /mnt/home/ldesgoui
$ nix run github:NixOS/nixpkgs/refs/pull/365403/head#nixos-install -- --flake github:ldesgoui/computers#sniper
```
