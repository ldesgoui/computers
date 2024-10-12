{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  # XXX: I found these when troubleshooting the hang/reboot issues
  boot.kernelParams = [ "rcu_nocbs=0-15" "idle=nomwait" ];

  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
}
