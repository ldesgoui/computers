_:
{
  system.stateVersion = "24.11";

  home-manager.users.ldesgoui = {
    home.stateVersion = "24.11";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tailscale = {
    enable = true;
  };
}
