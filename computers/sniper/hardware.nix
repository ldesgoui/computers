{ modulesPath, ... }: {
  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "virtio_pci"
    "virtio_blk"
    "aesni-intel"
    "cryptd"
  ];

  boot.kernelModules = [
    "kvm-amd"
  ];
}
