{ config, pkgs, ... }:
let
  inherit (config.disko) rootMountPoint;
in
{
  disko = {
    devices.nodev.root = {
      fsType = "tmpfs";
      mountpoint = "/";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=755"
      ];
    };

    devices.disk.transcend-mte110s = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-eui.48373831393032314ce0001838302020";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          swap = {
            size = "7G";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };

          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "bagel";
            };
          };
        };
      };
    };

    devices.zpool.bagel = {
      type = "zpool";

      options = {
        ashift = "12"; # 2^12 sectors
        autotrim = "on"; # good happy for SSDs
        cachefile = "none"; # trying shit
        compatibility = "openzfs-2.3-linux";
      };

      rootFsOptions = {
        canmount = "off";
        mountpoint = "none";

        recordsize = "1M";

        compression = "zstd-3"; # lil harder than lz4

        acltype = "posix";
        atime = "off"; # don't care about access times
        dnodesize = "auto"; # more efficient than legacy
        xattr = "sa"; # enhances perf for acltype=posix and dnodesize=auto

        utf8only = "on";
        normalization = "formD";
      };

      datasets = {
        heavy-lockbox = {
          type = "zfs_volume";
          size = "64M";
          content = {
            type = "luks";
            name = "heavy-keys";

            passwordFile = "/tmp/oh-god-dont-leak/heavy-lockbox";
            settings.allowDiscards = true;

            preCreateHook = ''
              ${pkgs.xkcdpass}/bin/xkcdpass -n 10 > /tmp/oh-god-dont-leak/heavy-lockbox
            '';

            content = {
              type = "filesystem";
              format = "ext4";
              postCreateHook = ''
                dir=$(mktemp -td heavy-keys-XXXXX)
                mount /dev/mapper/heavy-keys $dir
                cp -r /tmp/oh-god-dont-leak/heavy $dir/heavy
                umount $dir
              '';
            };
          };
        };

        heavy = {
          type = "zfs_fs";
          options = {
            encryption = "on";
            keylocation = "file:///tmp/oh-god-dont-leak/heavy";
            keyformat = "passphrase";
          };

          preCreateHook = ''
            ${pkgs.xkcdpass}/bin/xkcdpass -n 10 > /tmp/oh-god-dont-leak/heavy
          '';
        };

        "heavy/nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options = {
            exec = "on";
          };
        };

        # Just in case
        "heavy/var" = {
          type = "zfs_fs";
          mountpoint = "/var";
        };

        "heavy/nixos" = {
          type = "zfs_fs";
          mountpoint = "/var/lib/nixos";
        };

        "heavy/systemd" = {
          type = "zfs_fs";
          mountpoint = "/var/lib/systemd";
          postMountHook = ''
            systemd-machine-id-setup --root ${rootMountPoint}/var/lib/systemd
          '';
        };

        "heavy/journald" = {
          type = "zfs_fs";
          mountpoint = "/var/log/journal";
        };
      };
    };
  };
}
