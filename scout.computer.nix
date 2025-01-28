{ lib, self, inputs, ... }: {
  system = "x86_64-linux";

  modules = [
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ]
  ++ lib.mapAttrsToList
    (name: module: if lib.hasPrefix "scout-" name then module else { })
    self.nixosModules
  ++ builtins.attrValues {
    inherit (self.nixosModules)
      nixos-zfs

      profiles-defaults
      profiles-nix
      profiles-networkd
      profiles-ssh
      profiles-zfs-datasets

      profiles-acme

      age-rekey-settings
      ;
  };
}
