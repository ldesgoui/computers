{ lib, inputs, ... }: {
  nix.nixPath = lib.mkForce [
    "nixpkgs=${inputs.nixpkgs}"
    "nixos=${inputs.nixpkgs}"
  ];

  nix.registry.nixos.flake = inputs.nixpkgs;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}
