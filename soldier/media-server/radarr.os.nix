_:
{
  services.radarr = {
    enable = true;
  };

  services.nginx.virtualHosts."radarr.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:7878";
  };

  zfs.datasets.main.enc.services.radarr = {
    mountPoint = "/var/lib/radarr"; # Weird hardcode
  };
}
