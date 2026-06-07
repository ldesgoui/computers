{ lib, inputs, ... }: {
  flake.nixosConfigurations.heavy =
    let
      facter = lib.importJSON ./facter.json;
    in
    inputs.nixpkgs-unstable.lib.nixosSystem {
      inherit (facter) system;

      modules = [
        inputs.disko.nixosModules.default
        inputs.disko-zfs.nixosModules.default
        {
          boot.loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };

          boot.initrd = {
            systemd.enable = true;
          };

          boot.zfs.forceImportRoot = false;

          hardware.facter.report = facter;

          networking = {
            # Use the same default hostID as the NixOS install ISO and nixos-anywhere.
            # This allows us to import zfs pool without using a force import.
            # ZFS has this as a safety mechanism for networked block storage (ISCSI), but
            # in practice we found it causes more breakages like unbootable machines,
            # while people using ZFS on ISCSI is quite rare.
            hostId = "8425e349";

            hostName = "heavy";
            useNetworkd = true;
          };

          nix = {
            channel.enable = false;

            nixPath = lib.mkForce [
              "nixpkgs=${inputs.nixpkgs-unstable}"
              "nixos=${inputs.nixpkgs-unstable}"
            ];

            optimise.automatic = true;

            registry = {
              nixos.flake = inputs.nixpkgs-unstable;
            };

            settings = {
              experimental-features = [ "nix-command" "flakes" ];
              trusted-users = [ "@wheel" ];
            };
          };

          system.stateVersion = "25.11";

          time.timeZone = "Europe/Paris";

          users = {
            mutableUsers = false;
            users.root.initialPassword = "toor";
          };
        }
        {
          disko.devices.disk.transcend-mte110s = {
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

          disko.devices.zpool.bagel = {
            type = "zpool";

            options = {
              ashift = "12"; # 2^12 sectors
              autotrim = "on"; # good happy for SSDs
              cachefile = "none"; # trying shit
              compatibility = "openzfs-2.3-linux";
            };

            rootFsOptions = {
              canmount = "off";

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
              heavy-keys = {
                type = "zfs_volume";
                size = "4M";
                content = {
                  type = "luks";
                  name = "heavy-keys";
                  settings.allowDiscards = true;
                  passwordFile = "/tmp/heavy-lockbox";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/mnt/heavy-keys";
                    postCreateHook = ''
                      dd bs=32 count=1 if=/dev/urandom of=/mnt/heavy-keys/zfs
                    '';
                  };
                };
              };

              heavy = {
                type = "zfs_fs";
                options = {
                  encryption = "on";
                  keylocation = "file:///mnt/heavy-keys/zfs";
                  keyformat = "raw";
                };
              };

              "heavy/rootfs" = {
                type = "zfs_fs";
                mountpoint = "/";
              };

              "heavy/nix" = {
                type = "zfs_fs";
                mountpoint = "/nix";
                options = {
                  exec = "on";
                };
              };

              "heavy/nixos" = {
                type = "zfs_fs";
                mountpoint = "/var/lib/nixos";
              };

              "heavy/systemd" = {
                type = "zfs_fs";
                mountpoint = "/var/lib/systemd";
                postCreateHook = ''
                  ln -snfT /var/lib/systemd/machine-id /etc/machine-id
                  systemd-machine-id-setup
                '';
              };

              "heavy/journald" = {
                type = "zfs_fs";
                mountpoint = "/var/log/journal";
              };
            };
          };
        }
      ];
    };
}
