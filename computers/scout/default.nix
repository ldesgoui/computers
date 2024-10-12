{ config, inputs, ... }: {
  flake.nixosConfigurations = {
    scout = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./nixos.nix
        ./hardware.nix
        ./storage.nix

        ../../nixos/ldesgoui.nix
        ../../nixos/zfs.nix

        ../../nixos/profiles/defaults.nix
        ../../nixos/profiles/nix.nix
        ../../nixos/profiles/zfs-datasets.nix
      ] ++ builtins.attrValues {
        inherit (config.flake.nixosModules) flake-inputs;
        inherit (inputs.home-manager.nixosModules) home-manager;
        inherit (inputs.nixos-hardware.nixosModules) framework-11th-gen-intel;
      };
    };
  };
}
