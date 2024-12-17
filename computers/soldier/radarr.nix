{
  services.radarr = {
    enable = true;
  };

  zfs.datasets.main._.enc._.services._.radarr = {
    mountPoint = "/var/lib/radarr"; # Weird hardcode
  };
}
