{
  networking.hostName = "sniper";

  system.stateVersion = "24.11";

  boot.initrd.kernelParams = [ "console=ttyS0" ];
}
