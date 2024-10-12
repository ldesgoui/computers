{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.initrd = {
    availableKernelModules = [ "nvme" ];
  };

  boot.zfs = {
    enableRecommended = true;
  };

  boot.zfs.pools.main = {
    vdevs = [ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNS0T108224Y-part2" ];

    properties = {
      ashift = "12";
      autotrim = "on";
      compatibility = "openzfs-2.1-linux";
    };
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNS0T108224Y-part1";
    fsType = "vfat";
  };

  networking.hostId = "11111111"; # For ZFS

  swapDevices = [{
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNS0T108224Y-part3";
  }];
}

