{
  services.bazarr = {
    enable = true;
  };

  zfs.datasets.main._.enc._.services._.bazarr = {
    mountPoint = "/var/lib/bazarr"; # Weird hardcode
  };
}
