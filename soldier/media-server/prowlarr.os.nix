_:
{
  services.prowlarr = {
    enable = true;
  };

  services.nginx.virtualHosts."prowlarr.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:9696";
  };

  zfs.datasets.main.enc.services.prowlarr = {
    mountPoint = "/var/lib/private/prowlarr"; # StateDirectory
  };
}
