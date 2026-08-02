{ inputs, ... }:
{ pkgs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) config;
    inherit (pkgs.stdenv.hostPlatform) system;
  };
in
{
  environment.systemPackages = [
    pkgs.claude-code
  ];

  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama-vulkan;
  };
}
