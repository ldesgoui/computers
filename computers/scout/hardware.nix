{
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" ];
  boot.kernelModules = [ "kvm-intel" ];

  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;

  powerManagement.cpuFreqGovernor = "powersave";

  services.fwupd = {
    enable = true;
    extraRemotes = [
      "lvfs-testing"
    ];
  };
}
