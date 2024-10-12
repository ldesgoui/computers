{ config, inputs, ... }: {
  flake.nixosConfigurations = {
    soldier = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./nixos.nix
        ./hardware.nix
        ./storage.nix

        ../../nixos/zfs.nix
        ../../nixos/ldesgoui.nix

        ../../nixos/profiles/defaults.nix
        ../../nixos/profiles/nix.nix
        ../../nixos/profiles/zfs-datasets.nix
      ] ++ builtins.attrValues {
        inherit (config.flake.nixosModules) flake-inputs;

        inherit (inputs.nixos-hardware.nixosModules)
          common-cpu-amd
          common-cpu-amd-pstate
          common-gpu-amd
          common-pc
          common-pc-ssd
          ;

        inherit (inputs.home-manager.nixosModules) home-manager;
      };
    };
  };
}
