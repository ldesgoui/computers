{ inputs, ... }:
{ lib, ... }: {
  nix.nixPath = lib.mkForce [
    "nixpkgs=${inputs.nixpkgs}"
    "nixos=${inputs.nixpkgs}"
  ];

  nix.registry = {
    nixos.flake = inputs.nixpkgs;
    unstable.flake = inputs.nixpkgs-unstable;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "@wheel" ];
  };
}
