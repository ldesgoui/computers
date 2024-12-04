{ lib, pkgs, ... }: {
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

        chatterino2
        streamlink

        moonlight-qt
        ;
    });

    services.kanshi = {
      enable = true;

      settings = [
        {
          profile = {
            name = "roaming";
            outputs = [{ criteria = "eDP-1"; status = "enable"; scale = 1.5; }];
          };
        }

        {
          profile = {
            name = "docked-living-room";
            outputs = [
              { criteria = "eDP-1"; status = "disable"; }
              {
                criteria = "LG Electronics LG ULTRAGEAR 103NTXREH162";
                status = "enable";
                mode = "3440x1440@99.99Hz";
              }
            ];
          };
        }

        {
          profile = {
            name = "docked-office";
            outputs = [
              { criteria = "eDP-1"; status = "disable"; }
              {
                criteria = "LG Electronics 34GN850 007NTRL7G022";
                status = "enable";
                mode = "3440x1440@160Hz";
              }
            ];
          };
        }
      ];
    };
  };

  programs.steam = {
    enable = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];

  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
  ];
}
