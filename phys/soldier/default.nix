{ lib, self, inputs, ... }: {
  flake.nixosConfigurations.soldier =
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        { networking.hostName = "soldier"; }
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
      ]
      ++ lib.mapAttrsToList
        (name: module: if lib.hasPrefix "soldier-" name then module else { })
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

        inherit (inputs.nixos-hardware.nixosModules)
          common-cpu-amd
          common-cpu-amd-pstate
          common-gpu-amd
          common-pc
          common-pc-ssd
          ;
      };
    };
}
