_:
{
  fileSystems."/boot" = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX0NA71896Y-part1";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX0NA71896Y-part2";
  }];

  zfs = {
    enableRecommended = true;
  };

  zfs.pools = {
    main = {
      vdevs = [
        {
          type = "mirror";
          devices = [
            "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX0NA71896Y-part3"
            "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5RRNJ0X500733Y"
          ];
        }
        {
          type = "mirror";
          devices = [
            "/dev/disk/by-id/ata-WDC_WDS200T2B0B-00YS70_20321R457706"
            "/dev/disk/by-id/ata-WDC_WDS200T2B0B-00YS70_204256440404"
          ];
        }
      ];

      properties = {
        ashift = "12";
        autotrim = "on";
        compatibility = "openzfs-2.2-linux";
      };
    };

    slow = {
      vdevs = [{
        type = "raidz1";
        devices = [
          "/dev/disk/by-id/ata-HITACHI_HUA723020ALA640_YFJZWDLA"
          "/dev/disk/by-id/ata-HITACHI_HUA723020ALA640_YFK03TGA"
          "/dev/disk/by-id/ata-HITACHI_HUA723020ALA640_YFK3TYWA"
        ];
      }];
      properties = {
        ashift = "12";
        compatibility = "openzfs-2.2-linux";
      };
    };
  };

  zfs.datasets = {
    slow = {
      properties = {
        atime = "off";
        normalization = "formD";
      };
    };

    slow.enc = {
      properties = {
        encryption = "on";
        keylocation = "prompt";
        keyformat = "passphrase";
      };
    };
  };
}
