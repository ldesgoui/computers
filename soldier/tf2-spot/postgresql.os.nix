_:
{ lib, pkgs, config, ... }: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;

    enableTCPIP = true;

    authentication = lib.mkOverride 10 ''
      local all all                 trust
      host  all all 100.101.0.18/32 trust
    '';
  };

  zfs.datasets.main = {
    enc.services.postgresql = {
      mountPoint = config.services.postgresql.dataDir;
    };
  };
}
