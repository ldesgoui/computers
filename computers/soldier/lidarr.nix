{
  services.lidarr = {
    enable = true;
  };

  zfs.datasets.main._.enc._.services._.lidarr = {
    mountPoint = "/var/lib/lidarr"; # Weird hardcode
  };
}
