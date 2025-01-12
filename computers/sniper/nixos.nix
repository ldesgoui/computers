{
  networking.hostName = "sniper";

  system.stateVersion = "24.11";

  boot.initrd.kernelParams = [ "console=ttyS0" ];

  services.openssh = {
    enable = true;
  };

  services.tailscale = {
    enable = true;
  };
}
