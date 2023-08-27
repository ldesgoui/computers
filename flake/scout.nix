{ config, lib, inputs, ... }: {
  flake.nixosConfigurations = {
    scout = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = builtins.attrValues {
        inherit (config.flake.nixosModules)
          flake-inputs
          zfs

          profiles-scout
          profiles-scout-hardware
          profiles-scout-storage

          profiles-defaults
          profiles-graphical
          profiles-nix
          profiles-sound
          profiles-user-ldesgoui
          profiles-zfs-datasets
          ;

        inherit (inputs.home-manager.nixosModules) home-manager;
        inherit (inputs.nixos-hardware.nixosModules) framework;
      };
    };
  };

  flake.nixosModules = {
    profiles-scout = { pkgs, ... }: {
      networking.hostName = "scout";

      # State versions
      system.stateVersion = "22.11";
      home-manager.users.ldesgoui.home.stateVersion = "22.11";

      # NixOS config
      hardware.opengl = {
        enable = true;
      };

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      networking.networkmanager.enable = true;
      users.users.ldesgoui.extraGroups = [ "networkmanager" ];

      programs.dconf.enable = true;

      # Home-manager config
      home-manager.users.ldesgoui = {
        programs.firefox = {
          enable = true;
        };
      };
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
    };
  };
}
