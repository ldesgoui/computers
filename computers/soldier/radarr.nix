{
  services.radarr = {
    enable = true;
  };

  services.nginx.virtualHosts."radarr.int.lde.sg" = {
    enableACME = true;
    forceSSL = true;
    locations."/". proxyPass = "http://localhost:7878";
  };

  zfs.datasets.main._.enc._.services._.radarr = {
    mountPoint = "/var/lib/radarr"; # Weird hardcode
  };
}
