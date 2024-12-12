{
  networking.hostName = "soldier";

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

  powerManagement.powertop.enable = true;

  networking.firewall.enable = false;

  services.openssh = {
    enable = true;
  };
}
