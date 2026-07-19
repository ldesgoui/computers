{ lib, self, inputs, ... }: {
  flake.nixosConfigurations.soldier =
    inputs.nixpkgs-old.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        { networking.hostName = "soldier"; }

        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
        self.nixosModules.age-rekey-settings

        inputs.microvm.nixosModules.host
        self.nixosModules.microvm-zfs-shares-host-legacy
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
