{ lib, self, inputs, ... }: {
  flake.nixosConfigurations.demoman =
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        { networking.hostName = "demoman"; }
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
      ]
      ++ lib.mapAttrsToList
        (name: module: if lib.hasPrefix "demoman-" name then module else { })
        self.nixosModules
      ++ builtins.attrValues {
        inherit (self.nixosModules)
          nixos-zfs

          profiles-defaults
          profiles-networkd
          profiles-nix
          profiles-ssh
          profiles-zfs-datasets

          age-rekey-settings
          ;
      };
    };
}
