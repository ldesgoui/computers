_:
{
  boot.loader = {
    systemd-boot.enable = true;
    # efi.canTouchEfiVariables = true;
  };

  boot.initrd = {
    availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
    systemd.enable = true;
  };

  boot = {
    kernelModules = [ "kvm-amd" ];

    # XXX: I found these when troubleshooting the hang/reboot issues
    kernelParams = [ "rcu_nocbs=0-15" "idle=nomwait" ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;
  };

  powerManagement.powertop.enable = true;
}
