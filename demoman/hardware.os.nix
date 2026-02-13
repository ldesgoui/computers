_:
{
  boot.loader = {
    systemd-boot.enable = true;
    # efi.canTouchEfiVariables = true;
  };

  boot.initrd = {
    availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" ];
    systemd.enable = true;
  };

  boot.kernelModules = [ "kvm-amd" ];

  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;
  };
}
