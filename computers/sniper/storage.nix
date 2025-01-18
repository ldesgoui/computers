{
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 8;
    };
    efi.canTouchEfiVariables = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-id/scsi-0SCW_sbs_volume-052039c2-63c0-460b-872c-e70f9aa62c19";
    fsType = "vfat";
  };

  networking.hostId = "88888888"; # For ZFS

  swapDevices = [{
    device = "/dev/disk/by-id/scsi-0SCW_sbs_volume-a45d3e8d-9b92-4a08-994f-8edeaf8d41ba";
  }];

  zfs = {
    enableRecommended = true;
  };

  zfs.pools.main = {
    vdevs = [ "/dev/disk/by-id/scsi-0SCW_b_ssd_volume-00aebd75-c0e5-42de-9d8c-1e043a7f6d59" ];

    properties = {
      ashift = "12";
      autotrim = "on";
      compatibility = "openzfs-2.2-linux";
    };
  };

  zfs.pools.block = {
    vdevs = [ "/dev/disk/by-id/scsi-0SCW_sbs_volume-6a48a976-9db2-4ac2-98a2-7cde547ebfb5" ];

    properties = {
      ashift = "12";
      autoexpand = "on";
      autotrim = "on";
      compatibility = "openzfs-2.2-linux";
    };
  };
}
