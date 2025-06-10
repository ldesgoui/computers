_:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.initrd = {
    availableKernelModules = [ "mpt3sas" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
    systemd.enable = true;
  };

  boot = {
    kernelModules = [ "kvm-amd" ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    # graphics.enable = true;
  };

  powerManagement.powertop.enable = true;
}
