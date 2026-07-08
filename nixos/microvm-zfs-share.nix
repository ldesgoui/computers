{ self, ... }: {
  flake.nixosModules = {
    microvm-zfs-shares-guest = { config, lib, utils, ... }:
      let
        inherit (lib) types;
        cfg = config.microvm.zfs;
      in
      {
        options = {
          microvm.zfs = {
            root = {
              options = lib.mkOption {
                type = types.attrsOf types.str;
                default = {
                  canmount = "off";
                  mountpoint = "none";
                };
              };

              encryption-passphrase-age-rekeyFile = lib.mkOption {
                type = types.nullOr types.path;
                default = null;
              };
            };

            datasets = lib.mkOption {
              type = types.attrsOf (types.submodule {
                options = {
                  mountPoint = lib.mkOption {
                    type = types.path;
                  };

                  options = lib.mkOption {
                    type = types.attrsOf types.str;
                    default = { };
                  };

                  mountOptions = lib.mkOption {
                    type = types.listOf types.str;
                    default = [ ];
                  };
                };
              });
            };
          };
        };

        config = {
          microvm.zfs.root.options =
            lib.mkIf (cfg.root.encryption-passphrase-age-rekeyFile != null) {
              encryption = "on";
              keyformat = "passphrase";
              keylocation = "file:///run/agenix/${config.networking.hostName}-keys"; # HACK: not happy about this
            };

          microvm.shares =
            lib.mapAttrsToList
              (name: ds: {
                proto = "virtiofs";
                tag = utils.escapeSystemdPath name;
                source = "/var/lib/microvms/${config.networking.hostName}/shares/${name}";
                mountPoint = ds.mountPoint;
              })
              cfg.datasets;
        };
      };

    microvm-zfs-shares-host = { config, lib, utils, ... }: {
      options = {
        zfsSharesFor = lib.mkOption {
          type = with lib.types; attrsOf (listOf str);
          default = { };
        };
      };

      config = {
        age.secrets = lib.mkMerge (lib.mapAttrsToList
          (_: hostNames: lib.mkMerge (map
            (hostName:
              let
                rekeyFile =
                  self.nixosConfigurations.${hostName}.config.microvm.zfs.root.encryption-passphrase-age-rekeyFile;
              in
              if rekeyFile != null then
                {
                  "${hostName}-keys" = {
                    rekeyFile = rekeyFile;
                    generator.script = "passphrase";
                  };
                }
              else
                { }
            )
            hostNames
          ))
          config.zfsSharesFor);

        disko.devices.zpool = builtins.mapAttrs
          (pool: hostNames: lib.mkMerge (map
            (hostName:
              let
                cfg = self.nixosConfigurations.${hostName}.config.microvm.zfs;
              in
              {
                datasets = {
                  "${hostName}" = {
                    type = "zfs_fs";
                    options = cfg.root.options;
                  };
                }
                // lib.mapAttrs'
                  (name: ds: {
                    name = "${hostName}/${name}";
                    value = {
                      type = "zfs_fs";
                      options = ds.options;
                      mountpoint = "/var/lib/microvms/${hostName}/shares/${name}";
                      mountOptions = [
                        "x-systemd.required-by=microvm-virtiofsd@${hostName}.service"
                        "x-systemd.before=microvm-virtiofsd@${hostName}.service"
                      ] ++ ds.mountOptions;
                    };
                  })
                  cfg.datasets;
              })
            hostNames))
          config.zfsSharesFor;
      };
    };

    microvm-zfs-shares-host-legacy = { config, lib, utils, ... }: {
      options = {
        zfsSharesFor = lib.mkOption {
          type = with lib.types; attrsOf (listOf str);
          default = { };
        };
      };

      config = {
        age.secrets = lib.mkMerge (lib.mapAttrsToList
          (_: hostNames: lib.mkMerge (map
            (hostName:
              let
                rekeyFile =
                  self.nixosConfigurations.${hostName}.config.microvm.zfs.root.encryption-passphrase-age-rekeyFile;
              in
              if rekeyFile != null then
                {
                  "${hostName}-keys" = {
                    rekeyFile = rekeyFile;
                    generator.script = "passphrase";
                  };
                }
              else
                { }
            )
            hostNames
          ))
          config.zfsSharesFor);

        zfs.datasets = builtins.mapAttrs
          (pool: hostNames: {
            children = builtins.listToAttrs (map
              (hostName:
                let
                  cfg = self.nixosConfigurations.${hostName}.config.microvm.zfs;
                in
                {
                  name = hostName;
                  value = {
                    properties = cfg.root.options;
                    children = lib.mapAttrs'
                      (name: ds: {
                        inherit name;
                        value = {
                          properties = ds.options;
                          mountPoint = "/var/lib/microvms/${hostName}/shares/${name}";
                          options = [
                            "x-systemd.required-by=microvm-virtiofsd@${hostName}.service"
                            "x-systemd.before=microvm-virtiofsd@${hostName}.service"
                          ] ++ ds.mountOptions;
                        };
                      })
                      cfg.datasets;
                  };
                })
              hostNames);
          })
          config.zfsSharesFor;
      };
    };
  };
}
