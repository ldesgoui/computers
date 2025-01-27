_:
{
  system.stateVersion = "24.11";

  home-manager.users.ldesgoui = {
    home.stateVersion = "24.11";
  };

  services.openssh = {
    enable = true;
  };

  services.tailscale = {
    enable = true;
  };
}
