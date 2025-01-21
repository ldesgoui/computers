{ lib, self, inputs, ... }: {
  system = "x86_64-linux";

  modules = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ]
  ++ lib.mapAttrsToList
    (name: module: if lib.hasPrefix "soldier-" name then module else { })
    self.nixosModules
  ++ builtins.attrValues {
    inherit (self.nixosModules)
      nixos-zfs

      profiles-defaults
      profiles-acme
      profiles-nix
      profiles-zfs-datasets

      age-rekey-settings
      ;

    inherit (inputs.nixos-hardware.nixosModules)
      common-cpu-amd
      common-cpu-amd-pstate
      common-gpu-amd
      common-pc
      common-pc-ssd
      ;
  };
}
