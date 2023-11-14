{ config, lib, inputs, ... }: {
  flake.nixosConfigurations = {
    scout = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = builtins.attrValues {
        inherit (config.flake.nixosModules)
          flake-inputs
          ldesgoui
          zfs

          profiles-scout
          profiles-scout-hardware
          profiles-scout-storage

          profiles-defaults
          profiles-nix
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

      system.stateVersion = "22.11";

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      ldesgoui = {
        enable = true;
        graphical = true;
        dev.nix = true;
        dev.bash = true;
      };

      networking.networkmanager.enable = true;
      users.users.ldesgoui.extraGroups = [ "networkmanager" ];

      home-manager.users.ldesgoui = {
        home.stateVersion = "22.11";

        home.packages = (builtins.attrValues {
          inherit (pkgs)
            wireguard-tools
            mumble
            ;
        });

        services.kanshi = {
          enable = true;

          profiles.roaming = {
            outputs = [{ criteria = "eDP-1"; status = "enable"; scale = 1.5; }];
          };

          profiles.dp-extension = {
            outputs = [
              { criteria = "eDP-1"; status = "disable"; }
              { criteria = "DP-1"; status = "enable"; mode = "3440x1440@160Hz"; }
            ];
          };

          profiles.usbc-docked = {
            outputs = [
              { criteria = "eDP-1"; status = "disable"; }
              { criteria = "DP-4"; status = "enable"; mode = "3440x1440@99.99Hz"; }
            ];
          };
        };
      };

      programs.steam = {
        enable = true;
      };

      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
      ];

      networking.nameservers = [
        "8.8.8.8"
        "8.8.4.4"
      ];
    };

    profiles-scout-hardware = {
      boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" ];
      boot.kernelModules = [ "kvm-intel" ];

      hardware.enableRedistributableFirmware = true;
      hardware.opengl.enable = true;

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
