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
            rootFsOptions = lib.mkOption {
              type = types.attrsOf types.str;
              default = {
                canmount = "off";
                mountpoint = "none";

                encryption = "on";
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
                    options = cfg.rootFsOptions;
                  };
                }
                // lib.mapAttrs'
                  (name: ds: {
                    name = "${hostName}/${name}";
                    value = {
                      type = "zfs_fs";
                      mountpoint = "/var/lib/microvms/${hostName}/shares/${name}";

                      options = ds.options;
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
  };
}
