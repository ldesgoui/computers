{
  description = "Configurations for computers I operate";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    helix = {
      url = "github:helix-editor/helix/22.12";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil/2023-01-01";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      imports = [
        ./flake/dev.nix

        ./flake/scout.nix
        ./flake/soldier.nix
        # ./flake/pyro.nix
        # ./flake/sniper.nix
      ];

      flake.nixosModules = {
        zfs = ./nixos/zfs.nix;

        profiles-zfs-datasets = ./nixos/profiles/zfs-datasets.nix;
      };
    };
}
