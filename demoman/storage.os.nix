_:
{
  fileSystems."/boot" = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_with_Heatsingk_1TB_S6WSNS0W506202F-part1";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_with_Heatsingk_1TB_S6WSNS0W506202F-part3";
  }];

  zfs = {
    enableRecommended = true;
  };

  zfs.pools.main = {
    vdevs = [ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_with_Heatsingk_1TB_S6WSNS0W506202F-part2" ];

    properties = {
      ashift = "12";
      autotrim = "on";
      compatibility = "openzfs-2.1-linux";
    };
  };
}

