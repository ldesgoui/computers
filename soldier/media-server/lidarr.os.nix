_:
{
  services.lidarr = {
    enable = true;
  };

  services.nginx.virtualHosts."lidarr.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:8686";
  };

  zfs.datasets.main.enc.services.lidarr = {
    mountPoint = "/var/lib/lidarr"; # Weird hardcode
  };
}
