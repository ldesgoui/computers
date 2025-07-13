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
      # +----+---+---+---+---+---+---+
      # | 20 | 7   7 | 7   7 | 7   7 |
      # +----+-------+-------+---+---+
      # |  6 | 6     |     6 |       |
      # |  6 |     6 |       | 6     |
      # |  6 |       | 6     |     6 |
      # |  1 | 1     | 1     | 1     |
      # |  1 |     1 |     1 |     1 |
      # +----+---+---+---+---+---+---+
      vdevs =
        let
          a = "/dev/disk/by-id/wwn-0x5000c500f4784a67";
          b1 = "/dev/disk/by-id/wwn-0x6000c500d81c4aef0000000000000000";
          b2 = "/dev/disk/by-id/wwn-0x6000c500d81c4aef0001000000000000";
          c1 = "/dev/disk/by-id/wwn-0x6000c500d8147dd30000000000000000";
          c2 = "/dev/disk/by-id/wwn-0x6000c500d8147dd30001000000000000";
          d1 = "/dev/disk/by-id/wwn-0x6000c500d81432230000000000000000";
          d2 = "/dev/disk/by-id/wwn-0x6000c500d81432230001000000000000";
        in
        [
          { type = "raidz"; devices = [ "${a}-part1" "${b1}-part1" "${c2}-part1" ]; }
          { type = "raidz"; devices = [ "${a}-part2" "${b2}-part1" "${d1}-part1" ]; }
          { type = "raidz"; devices = [ "${a}-part3" "${c1}-part1" "${d2}-part1" ]; }
          { type = "raidz"; devices = [ "${a}-part4" "${b1}-part2" "${c1}-part2" "${d1}-part2" ]; }
          { type = "raidz"; devices = [ "${a}-part5" "${b2}-part2" "${c2}-part2" "${d2}-part2" ]; }
        ];

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
