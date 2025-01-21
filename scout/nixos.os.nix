_:
{ lib, pkgs, ... }: {

  users.users.ldesgoui.homeMode = "711"; # services need x

  networking.networkmanager.enable = true;
  users.users.ldesgoui.extraGroups = [ "networkmanager" ];

  home-manager.users.ldesgoui = {
    home.packages = (builtins.attrValues {
      inherit (pkgs)
        wireguard-tools
        mumble

        chatterino2
        streamlink

        moonlight-qt

        keepassxc
        ;
    });
  };

  programs.steam = {
    enable = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];

  services.tailscale = {
    enable = true;
  };

  services.pcscd = {
    enable = true;
  };
}
