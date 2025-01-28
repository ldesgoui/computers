_:
{ lib, pkgs, ... }: {
  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrG1pOTv5Oki3p6jiqhb5ax99H6blhcL8EHvSd4DfyD";
  };

  users.users.ldesgoui.homeMode = "711"; # services need x

  networking.networkmanager.enable = true;
  users.users.ldesgoui.extraGroups = [ "networkmanager" ];

  home-manager.users.ldesgoui = {
    home.packages = (builtins.attrValues {
      inherit (pkgs)
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

  # TODO: i fucked up :'(
  boot.zfs.forceImportRoot = true;
}
