{ config, inputs, ... }: {
  flake.nixosConfigurations = {
    sniper = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./nixos.nix
        ./hardware.nix
        ./storage.nix

        ./nginx.nix
        ./murmur.nix

        ../../nixos/zfs.nix
        ../../nixos/ldesgoui.nix

        ../../nixos/profiles/defaults.nix
        ../../nixos/profiles/nix.nix
        ../../nixos/profiles/zfs-datasets.nix

        config.flake.nixosModules.flake-inputs
        # config.flake.nixosModules.age-rekey-settings

        inputs.home-manager.nixosModules.home-manager

        # inputs.agenix.nixosModules.default
        # inputs.agenix-rekey.nixosModules.default
      ];
    };
  };
}
