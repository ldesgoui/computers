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

    gullywash = {
      vdevs = [{
        type = "raidz2";
        devices = [
          "/dev/disk/by-id/wwn-0x6000c500d81c4aef0000000000000000"
          "/dev/disk/by-id/wwn-0x6000c500d81c4aef0001000000000000"
          "/dev/disk/by-id/wwn-0x6000c500d8147dd30000000000000000"
          "/dev/disk/by-id/wwn-0x6000c500d8147dd30001000000000000"
        ];
      }];

      properties = {
        ashift = "12";
        autotrim = "on";
        compatibility = "openzfs-2.2-linux";
      };
    };
  };


  zfs.datasets = {
    gullywash = {
      properties = {
        acltype = "posix";
        atime = "off";
        compression = "on";
        dnodesize = "auto";
        normalization = "formD";
        relatime = "on";
        xattr = "sa";
      };
    };
  };
}
