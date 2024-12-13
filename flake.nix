{
  description = "Configurations for computers I operate";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/x86_64-linux";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        systems.follows = "systems";
      };
    };

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        ./dev.nix

        ./computers/scout
        ./computers/soldier
        ./computers/sniper

        inputs.agenix-rekey.flakeModule
      ];

      flake.nixosModules = {
        flake-inputs = { _module.args.inputs = inputs; };
        age-rekey-settings = { config, ... }: {
          age.rekey = {
            masterIdentities = [{
              identity = "${./.}/master.age";
              pubkey = "age1muncma6qvwmetka89lrtyeslkfg2ks8g8kp42gt299zraflrcpusa08eus";
            }];
            storageMode = "local";
            localStorageDir = "${inputs.self}/computers/${config.networking.hostName}/.secrets";
          };
        };
      };

      perSystem = { ... }: {
        agenix-rekey.nixosConfigurations = {
          inherit (inputs.self.nixosConfigurations)
            soldier
            ;
        };
      };
    };
}
