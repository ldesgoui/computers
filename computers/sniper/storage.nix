{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.zfs = {
    enableRecommended = true;
  };

  boot.zfs.pools.main = {
    vdevs = [ "/dev/disk/by-id/TODO" ];

    properties = {
      ashift = "12";
      autotrim = "on";
      compatibility = "openzfs-2.1-linux";
    };
  };

  boot.zfs.pools.block = {
    vdevs = [ "/dev/disk/by-id/TODO" ];

    properties = {
      ashift = "12";
      autoexpand = "on";
      autotrim = "on";
      compatibility = "openzfs-2.1-linux";
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-id/TODO";
    fsType = "vfat";
  };

  networking.hostId = "88888888"; # For ZFS

  swapDevices = [{
    device = "/dev/disk/by-id/TODO";
  }];
}
