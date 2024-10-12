{
  system.stateVersion = "22.11";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ldesgoui = {
    home.stateVersion = "22.11";
  };

  ldesgoui = {
    enable = true;
    graphical = true;
    dev.nix = true;
    dev.bash = true;
  };
}
