{ config, lib, inputs, ... }: {
  flake.nixosConfigurations = {
    soldier = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = builtins.attrValues {
        inherit (config.flake.nixosModules)
          flake-inputs
          zfs

          profiles-soldier
          profiles-soldier-hardware
          profiles-soldier-storage

          profiles-defaults
          profiles-nix
          profiles-sound
          profiles-user-ldesgoui
          profiles-zfs-datasets
          ;

        inherit (inputs.nixos-hardware.nixosModules)
          common-cpu-amd
          common-cpu-amd-pstate
          common-gpu-amd
          common-pc
          common-pc-ssd
          ;
      };
    };
  };

  flake.nixosModules = {
    profiles-soldier = {
      system.stateVersion = "22.11";
    };

    profiles-soldier-hardware = {
      boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
      boot.kernelModules = [ "kvm-amd" ];

      # XXX: I found these when troubleshooting the hang/reboot issues
      boot.kernelParams = [ "rcu_nocbs=0-15" "idle=nomwait" ];

      hardware.enableRedistributableFirmware = true;
      hardware.video.hidpi.enable = true;
      hardware.opengl.enable = true;
    };

    profiles-soldier-storage = {
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
          compatibility = "openzfs-2.1-linux";
        };
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX0NA71896Y-part1";
        fsType = "vfat";
      };

      networking.hostId = "26afaa70"; # For ZFS

      swapDevices = [{
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNX0NA71896Y-part2";
      }];
    };
  };
}
