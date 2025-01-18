{ config, inputs, ... }: {
  flake.nixosConfigurations = {
    sniper = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./nixos.nix
        ./hardware.nix
        ./storage.nix

        ../../nixos/zfs.nix

        ../../nixos/profiles/defaults.nix
        ../../nixos/profiles/nix.nix
        ../../nixos/profiles/zfs-datasets.nix
      ] ++ builtins.attrValues {
        inherit (config.flake.nixosModules) flake-inputs;
      };
    };
  };
}
