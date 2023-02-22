{ config, lib, inputs, ... }: {
  flake.nixosConfigurations = {
    scout = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = builtins.attrValues {
        inherit (config.flake.nixosModules)
          zfs

          profiles-scout
          profiles-scout-hardware
          profiles-scout-storage

          profiles-zfs-datasets
          ;

        inherit (inputs.nixos-hardware.nixosModules) framework;
      };
    };
  };

  flake.nixosModules = {
    profiles-scout = {
      system.stateVersion = "22.11";
    };

    profiles-scout-hardware = {
      boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" ];
      boot.kernelModules = [ "kvm-intel" ];

      hardware.enableRedistributableFirmware = true;
      hardware.video.hidpi.enable = true;

      powerManagement.cpuFreqGovernor = "powersave";

      services.fwupd = {
        enable = true;
      };
    };

    profiles-scout-storage = {
      boot.initrd.availableKernelModules = [ "nvme" ];

      boot.zfs = {
        enableRecommended = true;
      };

      boot.zfs.pools.main = {
        vdevs = [ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNS0T108224Y-part2" ];

        properties = {
          ashift = "12";
          autotrim = "true";
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
    };
  };
}
