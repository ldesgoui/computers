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
          type = with lib.types; attrsOf str;
          default = { };
        };
      };

      config = {
        disko.devices.zpool = lib.mkMerge (lib.mapAttrsToList
          (hostName: pool: {
            "${pool}" = {
              datasets = lib.mapAttrs'
                (name: ds: {
                  name = "${hostName}/${name}";
                  value = {
                    type = "zfs_fs";
                    mountpoint = "/var/lib/microvms/${hostName}/shares/${name}";

                    options = ds.options;
                    mountOptions = [ "nofail" ] ++ ds.mountOptions;
                  };
                })
                self.nixosConfigurations.${hostName}.config.microvm.zfs.datasets;
            };
          })
          config.zfsSharesFor);

        systemd.services = lib.mkMerge (lib.mapAttrsToList
          (hostName: _:
            let
              mounts =
                lib.mapAttrsToList
                  (name: _: (utils.escapeSystemdPath "/var/lib/microvms/${hostName}/shares/${name}") + ".mount")
                  self.nixosConfigurations.${hostName}.config.microvm.zfs.datasets;
            in
            {
              "microvm-virtiofs@${hostName}" = {
                overrideStrategy = "asDropin";
                requires = mounts;
                after = mounts;
              };
            })
          config.zfsSharesFor);
      };
    };
  };
}
