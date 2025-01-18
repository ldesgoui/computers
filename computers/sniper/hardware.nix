{ modulesPath, ... }: {
  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "virtio_pci"
    "virtio_blk"
    "aesni-intel"
    "cryptd"
  ];

  boot.kernelParams = [ "console=ttyS0" ];

  boot.kernelModules = [
    "kvm-amd"
  ];
}
