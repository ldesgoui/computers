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

  boot.kernelModules = [ "kvm-intel" ];

  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;
    bluetooth.enable = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  services.fwupd = {
    enable = true;
    extraRemotes = [
      "lvfs-testing"
    ];
  };
}
