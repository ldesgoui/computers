{ lib, self, inputs, ... }: {
  system = "x86_64-linux";

  modules = [
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
  ]
  ++ lib.mapAttrsToList
    (name: module: if lib.hasPrefix "scout-" name then module else { })
    self.nixosModules
  ++ builtins.attrValues {
    inherit (self.nixosModules)
      nixos-zfs

      profiles-defaults
      profiles-nix
      profiles-ssh
      profiles-zfs-datasets

      profiles-acme
      ;
  };
}
