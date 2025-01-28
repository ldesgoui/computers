{ inputs, ... }:
{ lib, ... }: {
  nix.channel.enable = false;

  nix.nixPath = lib.mkForce [
    "nixpkgs=${inputs.nixpkgs}"
    "nixos=${inputs.nixpkgs}"
  ];

  nix.optimise = {
    automatic = true;
  };

  nix.registry = {
    nixos.flake = inputs.nixpkgs;
    unstable.flake = inputs.nixpkgs-unstable;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "@wheel" ];
  };
}
