_:
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
    device = bssd "598d1d74-ee70-4676-a705-c5e3dfa4a246";
    fsType = "vfat";
  };

  swapDevices = [{
    device = bssd "1a2f6f2e-5ed8-4128-a5cb-5c186e338502";
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
    vdevs = [ (bssd "99d05e0e-dcb9-44fd-9a5b-2171078e0d9a") ];

    properties = {
      ashift = "12";
      autoexpand = "on";
      autotrim = "on";
      compatibility = "openzfs-2.2-linux";
    };
  };
}
