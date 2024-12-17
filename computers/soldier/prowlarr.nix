{
  services.prowlarr = {
    enable = true;
  };

  zfs.datasets.main._.enc._.services._.prowlarr = {
    mountPoint = "/var/lib/private/prowlarr"; # StateDirectory
  };
}
