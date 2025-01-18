{
  networking.hostName = "sniper";

  system.stateVersion = "24.11";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ldesgoui = {
    home.stateVersion = "24.11";
  };

  ldesgoui = {
    enable = true;
    graphical = false;
  };

  services.openssh = {
    enable = true;
  };

  services.tailscale = {
    enable = true;
  };
}
