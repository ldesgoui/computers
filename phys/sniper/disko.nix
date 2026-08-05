{ config, pkgs, ... }:
let
  inherit (config.disko) rootMountPoint;
in
{
  disko = {
    zfs.enable = true;

    devices.nodev.root = {
      fsType = "tmpfs";
      mountpoint = "/";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=755"
      ];
    };

    devices.disk.nvme = {
      type = "disk";
      device = "/dev/vda"; # Scaleway didn't set serial number of virtio disks :(
      content = {
        type = "gpt";
        partitions = {
          esp = {
            size = "256M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          swap = {
            size = "2G";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };

          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "harvest";
            };
          };
        };
      };
    };

    devices.zpool.harvest = {
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
        sniper = {
          type = "zfs_fs";
          options = {
            encryption = "on";
            # keylocation = "file:///tmp/oh-god-dont-leak/sniper.passphrase";
            keylocation = "prompt";
            keyformat = "passphrase";
          };

          preCreateHook = ''
            mkdir -p /tmp/oh-god-dont-leak
            ${pkgs.xkcdpass}/bin/xkcdpass -n 10 > /tmp/oh-god-dont-leak/sniper.passphrase
          '';
        };

        "sniper/nix-store" = {
          type = "zfs_fs";
          mountpoint = "/nix/store";
          options = {
            exec = "on";
          };
        };

        "sniper/nix-var" = {
          type = "zfs_fs";
          mountpoint = "/nix/var/nix";
        };

        "sniper/nix-db" = {
          type = "zfs_fs";
          mountpoint = "/nix/var/nix/db";
          options = {
            recordsize = "64K";
          };
        };

        "sniper/nix-log" = {
          type = "zfs_fs";
          mountpoint = "/nix/var/log";
        };

        "sniper/nixos" = {
          type = "zfs_fs";
          mountpoint = "/var/lib/nixos";
        };

        "sniper/systemd" = {
          type = "zfs_fs";
          mountpoint = "/var/lib/systemd";
          postMountHook = ''
            systemd-machine-id-setup
            cp /etc/machine-id ${rootMountPoint}/var/lib/systemd/
          '';
        };

        "sniper/journald" = {
          type = "zfs_fs";
          mountpoint = "/var/log/journal";
        };

        "sniper/ssh-host-keys" = {
          type = "zfs_fs";
          mountpoint = "/etc/ssh/host-keys";
        };

        # Catching /var/lib/ and /var/log/ because I'm still scared to erase my darlings
        "sniper/var-lib" = {
          type = "zfs_fs";
          mountpoint = "/var/lib";
        };

        "sniper/var-log" = {
          type = "zfs_fs";
          mountpoint = "/var/log";
        };
      };
    };
  };
}
