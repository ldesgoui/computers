_:
{ config, ... }:
let
  bssd = uuid: "/dev/disk/by-id/scsi-0SCW_b_ssd_volume-${uuid}";
in
{
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 8;
    };
    efi.canTouchEfiVariables = true;
  };

  fileSystems."/boot" = {
    device = bssd "6840b06a-bc08-4571-8571-1f2d9671cf4f";
    fsType = "vfat";
  };

  swapDevices = [{
    device = bssd "942774f9-55b8-4a61-be92-5c56b2506467";
  }];

  zfs = {
    enableRecommended = true;
  };

  zfs.pools.main = {
    vdevs = [ "/dev/vda" ];

    properties = {
      ashift = "12";
      autotrim = "on";
      compatibility = "openzfs-2.2-linux";
    };
  };

  zfs.pools.block = {
    vdevs = [ (bssd "6a149eb0-0a70-4c13-a6fa-584b6cf2a7b2") ];

    properties = {
      ashift = "12";
      autoexpand = "on";
      autotrim = "on";
      compatibility = "openzfs-2.2-linux";
    };
  };

  zfs.datasets.block = {
    inherit (config.zfs.datasets.main) properties;
  };
}
