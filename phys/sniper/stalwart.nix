{ config, lib, pkgs, ... }: {
  age.secrets.mx-tsig = {
    rekeyFile = ./mx-tsig.age;
    generator.script = "knot-tsig";
    settings.id = "sniper.mx.";
  };

  age.secrets.mx-tsig-just-the-secret = {
    rekeyFile = ./mx-tsig-just-the-secret.age;
    owner = "stalwart";
    generator.dependencies = { inherit (config.age.secrets) mx-tsig; };
    generator.script = { deps, decrypt, pkgs, ... }: ''
      ${decrypt} ${lib.escapeShellArg deps.mx-tsig.file} | ${pkgs.yq-go}/bin/yq '.key[0].secret'
    '';
  };

  environment.etc."stalwart/config.json".text = builtins.toJSON {
    "@type" = "RocksDb";
    path = "/var/lib/stalwart/db";
  };

  environment.systemPackages = [
    pkgs.stalwart_0_16
    pkgs.stalwart-cli
  ];

  systemd.services.stalwart = {
    wantedBy = [ "multi-user.target" ];

    environment.LD_PRELOAD = "${pkgs.mimalloc}/lib/libmimalloc.so.3";

    serviceConfig = {
      ExecStart = "${pkgs.stalwart_0_16}/bin/stalwart --config /etc/stalwart/config.json";

      StateDirectory = "stalwart";
      StateDirectoryMode = "0750";
      LogsDirectory = "stalwart";

      User = "stalwart";
      Group = "stalwart";

      # Bind standard privileged ports
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

      # Hardening
      DeviceAllow = [ "" ];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      PrivateDevices = true;
      PrivateUsers = false; # incompatible with CAP_NET_BIND_SERVICE
      ProcSubset = "pid";
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      UMask = "0077";
    };
  };

  users = {
    users.stalwart = {
      group = "stalwart";
      isSystemUser = true;
      home = "/var/lib/stalwart";
    };
    groups.stalwart = { };
  };

  disko.devices.zpool.harvest.datasets = {
    "sniper/stalwart" = {
      type = "zfs_fs";
      mountpoint = "/var/lib/stalwart";
      options = {
        recordsize = "64K";
      };
    };
  };
}
