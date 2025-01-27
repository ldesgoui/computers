_:
{ modulesPath, ... }: {
  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  boot.loader = {
    systemd-boot.enable = true;
    # efi.canTouchEfiVariables = true;
  };

  boot.initrd = {
    availableKernelModules = [
      "ata_piix"
      "virtio_pci"
      "virtio_blk"
      "aesni-intel"
      "cryptd"
    ];

    systemd.enable = true;
  };

  boot.kernelParams = [ "console=ttyS0" ];

  boot.kernelModules = [
    "kvm-amd"
  ];
}
