_:
{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkOption
    types
    mkIf
    mkDefault
    ;

  mkMoreDefault = lib.mkOverride (1000 - 100);

  cfg = config.zfs;

  module = {
    options = {
      zfs = {
        enableRecommended = lib.mkEnableOption "recommended options";

        pools = mkOption {
          type = with types; attrsOf (submodule poolModule);
          default = { };
        };

        datasets = mkOption {
          type = with types; attrsOf (submodule datasetModule);
          default = { };
        };
      };
    };

    config = {
      boot = mkIf cfg.enableRecommended {
        initrd.kernelModules = [ "zfs" ];

        supportedFilesystems = [ "zfs" ];

        zfs = {
          forceImportRoot = mkMoreDefault false;
        };
      };

      fileSystems = lib.mkMerge (
        mapDatasets (path: dataset:
          lib.mkIf (dataset.mountPoint != null) {
            "${dataset.mountPoint}" = {
              fsType = "zfs";
              device = builtins.concatStringsSep "/" path;
              inherit (dataset) options neededForBoot;
            };
          }
        )
      );

      networking = mkIf cfg.enableRecommended {
        # Use the same default hostID as the NixOS install ISO and nixos-anywhere.
        # This allows us to import zfs pool without using a force import.
        # ZFS has this as a safety mechanism for networked block storage (ISCSI), but
        # in practice we found it causes more breakages like unbootable machines,
        # while people using ZFS on ISCSI is quite rare.
        hostId = mkMoreDefault "8425e349";
      };

      system.activationScripts."zfs-pools".text = ''
        echo '[zfs-pools] Checking all zfs pools exist'
        ${lib.getExe config.system.build.zfsCreatePools}
      '';

      system.activationScripts."zfs-datasets" = {
        deps = [ "zfs-pools" ];
        text = ''
          echo '[zfs-datasets] Checking all zfs datasets exist'
          ${lib.getExe config.system.build.zfsCreateDatasets}
        '';
      };

      system.build = {
        zfsCreatePools = pkgs.writeShellApplication {
          name = "create-zpools";
          runtimeInputs = [ config.boot.zfs.package ];
          text = lib.concatMapStringsSep "\n\n" zpoolCreate (builtins.attrValues cfg.pools);
        };

        zfsCreateDatasets = pkgs.writeShellApplication {
          name = "create-datasets";
          runtimeInputs = [ config.boot.zfs.package ];
          text = builtins.concatStringsSep "\n\n" (mapDatasets zfsCreate);
        };
      };
    };
  };

  poolModule = { name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;
      };

      vdevs = mkOption {
        type = types.nonEmptyListOf vdevType;
      };

      properties = mkOption {
        type = with types; attrsOf str;
      };
    };
  };

  vdevType = with types; oneOf [
    str

    (submodule {
      options = {
        type = mkOption { type = str; };
        devices = mkOption { type = nonEmptyListOf str; };
      };
    })
  ];

  datasetModule = { config, options, ... }: {
    freeformType = with types; lazyAttrsOf (submodule datasetModule);

    options = {
      properties = mkOption {
        type = with types; attrsOf str;
        default = { };
      };

      mountPoint = mkOption {
        type = with types; nullOr str;
        default = null;
      };

      options = mkOption {
        type = with types; listOf str;
        default = [ "defaults" ];
      };

      neededForBoot = mkOption {
        type = types.bool;
        default = false;
      };

      children = mkOption {
        description = "Children datasets";
        type = with types; lazyAttrsOf (submodule datasetModule);
        default = { };
      };
    };

    config = lib.mkMerge [
      (mkIf (config.mountPoint == null) {
        properties.canmount = mkDefault "off";
        properties.mountpoint = mkDefault "none";
      })

      (mkIf (config.mountPoint != null) {
        properties.mountpoint = mkDefault "legacy";
      })

      { children = removeAttrs config (builtins.attrNames options); }
    ];
  };

  mapDatasets = f:
    let
      recurse = prevPath: ds:
        builtins.concatMap
          (name:
            let
              dataset = ds.${name};
              path = prevPath ++ [ name ];
            in
            [ (f path dataset) ] ++ recurse path dataset.children
          )
          (builtins.attrNames ds);
    in
    recurse [ ] cfg.datasets;

  attrsToProps = flag: attrs:
    builtins.concatLists (lib.mapAttrsToList (k: v: [ flag "${k}=${v}" ]) attrs);

  zpoolCreate = zpool:
    let
      pprops = attrsToProps "-o" zpool.properties;
      zprops = attrsToProps "-O" cfg.datasets.${zpool.name}.properties;
      vdevs = builtins.concatMap (v: if builtins.isString v then [ v ] else [ v.type ] ++ v.devices) zpool.vdevs;
    in
    ''
      zpool list '${zpool.name}' > /dev/null || \
      zpool create ${lib.escapeShellArgs ([zpool.name] ++ pprops ++ zprops ++ vdevs)}
    '';

  zfsCreate = path: ds:
    let
      name = builtins.concatStringsSep "/" path;
      props = attrsToProps "-o" ds.properties;
      comment = if builtins.length path == 1 then "# " else "";
    in
    ''
      ${comment}zfs list '${name}' > /dev/null || \
      ${comment}zfs create -u ${lib.escapeShellArgs ([name] ++ props)}
    '';
in
module
