{
  description = "Configurations for computers I operate";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        # "aarch64-linux"
        "x86_64-linux"
      ];

      imports = [
        ./parts/dev.nix

        ./parts/scout.nix
        ./parts/soldier.nix
        # ./parts/pyro.nix
        # ./parts/sniper.nix
      ];

      flake.nixosModules = {
        flake-inputs = { _module.args.inputs = inputs; };
        zfs = ./nixos/zfs.nix;
        ldesgoui = ./nixos/ldesgoui.nix;

        profiles-defaults = ./nixos/profiles/defaults.nix;
        profiles-nix = ./nixos/profiles/nix.nix;
        profiles-zfs-datasets = ./nixos/profiles/zfs-datasets.nix;
      };
    };
}
