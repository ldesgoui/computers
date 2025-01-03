{
  networking.hostName = "soldier";

  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8Kg9mUIe8h3RMjVJtXkTYK1cHxu5ZX8KHL/+EXlLhO";
  };

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

  users.users.ldesgoui.homeMode = "711"; # services need x

  powerManagement.powertop.enable = true;

  services.openssh = {
    enable = true;
  };
}
