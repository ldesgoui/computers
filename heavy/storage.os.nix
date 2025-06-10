_:
{
  fileSystems."/boot" = {
    device = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5RRNJ0X500733Y-part1";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5RRNJ0X500733Y-part2";
  }];

  zfs = {
    enableRecommended = true;
  };

  zfs.pools = {
    main = {
      vdevs = [ "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5RRNJ0X500733Y-part3" ];

      properties = {
        ashift = "12";
        autotrim = "on";
        compatibility = "openzfs-2.2-linux";
      };
    };
  };
}
