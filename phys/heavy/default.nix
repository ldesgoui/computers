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
        ({ config, pkgs, ... }:
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
                        mountpoint = "/mnt/heavy-keys";
                        postMountHook = ''
                          cp -r /tmp/oh-god-dont-leak/heavy ${rootMountPoint}/mnt/heavy-keys/heavy
                        '';
                      };
                    };
                  };

                  heavy = {
                    type = "zfs_fs";
                    options = {
                      # mountpoint = "/mnt/heavy-keys/hack"; # HACK: disko doesn't know about the dependency to heavy-keys
                      encryption = "on";
                      keylocation = "file:///mnt/heavy-keys/heavy";
                      keyformat = "passphrase";
                    };

                    preCreateHook = ''
                      ${pkgs.xkcdpass}/bin/xkcdpass -n 10 > /tmp/oh-god-dont-leak/heavy
                      mkdir -p /mnt/heavy-keys
                      ln -snfT /tmp/oh-god-dont-leak/heavy /mnt/heavy-keys/heavy 
                    '';
                    postCreateHook = ''
                      rm -r /mnt/heavy-keys
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
                      mkdir ${rootMountPoint}/etc
                      ln -snfT ${rootMountPoint}/var/lib/systemd/machine-id ${rootMountPoint}/etc/machine-id
                      systemd-machine-id-setup --root ${rootMountPoint}
                    '';
                  };

                  "heavy/journald" = {
                    type = "zfs_fs";
                    mountpoint = "/var/log/journal";
                  };
                };
              };
            };
          })
      ];
    };
}
