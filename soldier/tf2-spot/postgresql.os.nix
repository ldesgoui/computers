_:
{ lib, pkgs, config, ... }: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;

    authentication = lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };

  zfs.datasets.main = {
    enc.services.postgresql = {
      mountPoint = config.services.postgresql.dataDir;
    };
  };
}
