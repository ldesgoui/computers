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
      vdevs = [ "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX0NA71896Y-part3" ];

      properties = {
        ashift = "12";
        autotrim = "on";
        compatibility = "openzfs-2.2-linux";
      };
    };

    sata1 = {
      vdevs = [ "/dev/disk/by-id/ata-WDC_WDS200T2B0B-00YS70_20321R457706" ];
      properties = {
        ashift = "12";
        autotrim = "on";
        compatibility = "openzfs-2.2-linux";
      };
    };

    sata2 = {
      vdevs = [ "/dev/disk/by-id/ata-WDC_WDS200T2B0B-00YS70_204256440404" ];
      properties = {
        ashift = "12";
        autotrim = "on";
        compatibility = "openzfs-2.2-linux";
      };
    };
  };

  zfs.datasets = {
    sata1 = {
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

    sata1.enc = {
      properties = {
        encryption = "on";
        keylocation = "prompt";
        keyformat = "passphrase";
      };
    };

    sata2 = {
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

    sata2.enc = {
      properties = {
        encryption = "on";
        keylocation = "prompt";
        keyformat = "passphrase";
      };
    };
  };
}
