{ lib, self, inputs, ... }: {
  system = "x86_64-linux";

  modules = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ]
  ++ lib.mapAttrsToList
    (name: module: if lib.hasPrefix "sniper-" name then module else { })
    self.nixosModules
  ++ builtins.attrValues {
    inherit (self.nixosModules)
      nixos-zfs

      profiles-acme
      profiles-defaults
      profiles-headless
      profiles-networkd
      profiles-nix
      profiles-ssh
      profiles-zfs-datasets

      age-rekey-settings
      ;
  };
}
