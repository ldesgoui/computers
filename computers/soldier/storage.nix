{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.initrd = {
    availableKernelModules = [ "nvme" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX0NA71896Y-part1";
    fsType = "vfat";
  };

  networking.hostId = "26afaa70"; # For ZFS

  swapDevices = [{
    device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX0NA71896Y-part2";
  }];

  zfs = {
    enableRecommended = true;
  };

  zfs.pools.main = {
    vdevs = [
      {
        type = "mirror";
        devices = [
          "/dev/disk/by-id/ata-WDC_WDS200T2B0B-00YS70_20321R457706"
          "/dev/disk/by-id/ata-WDC_WDS200T2B0B-00YS70_204256440404"
        ];
      }
      {
        type = "log";
        devices = [ "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX0NA71896Y-part3" ];
      }
      {
        type = "cache";
        devices = [ "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX0NA71896Y-part4" ];
      }
    ];

    properties = {
      ashift = "12";
      autotrim = "on";
      compatibility = "openzfs-2.2-linux";
    };
  };
}
