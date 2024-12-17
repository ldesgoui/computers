{
  services.lidarr = {
    enable = true;
  };

  services.nginx.virtualHosts."lidarr.int.lde.sg" = {
    enableACME = true;
    forceSSL = true;
    locations."/". proxyPass = "http://localhost:8686";
  };

  zfs.datasets.main._.enc._.services._.lidarr = {
    mountPoint = "/var/lib/lidarr"; # Weird hardcode
  };
}
