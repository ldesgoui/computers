_:
{ config, ... }: {
  services.flood = {
    enable = true;
  };

  services.nginx.virtualHosts."flood.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString config.services.flood.port}";
  };

  zfs.datasets.main._.enc._.services._.flood = {
    mountPoint = "/var/lib/flood"; # StateDirectory
  };
}
