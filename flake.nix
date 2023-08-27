{
  description = "Configurations for computers I operate";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
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
        flake-inputs = { _module.args.inputs = inputs; };
        zfs = ./nixos/zfs.nix;

        profiles-defaults = ./nixos/profiles/defaults.nix;
        profiles-nix = ./nixos/profiles/nix.nix;
        profiles-sound = ./nixos/profiles/sound.nix;
        profiles-user-ldesgoui = ./nixos/profiles/user-ldesgoui.nix;
        profiles-zfs-datasets = ./nixos/profiles/zfs-datasets.nix;
      };
    };
}
