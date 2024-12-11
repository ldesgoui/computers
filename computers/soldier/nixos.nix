{
  system.stateVersion = "24.11";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ldesgoui = {
    home.stateVersion = "24.11";
  };

  ldesgoui = {
    enable = true;
    graphical = false;
    dev.nix = true;
    dev.bash = true;
  };

  powerManagement.powertop.enable = true;

  services.jellyfin = {
    enable = true;
  };
}
