{
  services.bazarr = {
    enable = true;
  };

  services.nginx.virtualHosts."bazarr.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/". proxyPass = "http://localhost:6767";
  };

  zfs.datasets.main._.enc._.services._.bazarr = {
    mountPoint = "/var/lib/bazarr"; # Weird hardcode
  };
}
