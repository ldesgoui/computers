{
  services.prowlarr = {
    enable = true;
  };

  services.nginx.virtualHosts."prowlarr.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/". proxyPass = "http://localhost:9696";
  };

  zfs.datasets.main._.enc._.services._.prowlarr = {
    mountPoint = "/var/lib/private/prowlarr"; # StateDirectory
  };
}
