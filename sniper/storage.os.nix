_:
{ config, ... }:
let
  bssd = uuid: "/dev/disk/by-id/scsi-0SCW_b_ssd_volume-${uuid}";
in
{
  boot.zfs = {
    devNodes = "/dev/disk/by-path";
  };

  fileSystems."/boot" = {
    device = bssd "942774f9-55b8-4a61-be92-5c56b2506467-part1";
    fsType = "vfat";
  };

  swapDevices = [{
    device = bssd "942774f9-55b8-4a61-be92-5c56b2506467-part2";
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
}
