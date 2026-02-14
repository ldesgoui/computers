{ inputs, ... }:
{ pkgs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) config system; };
in
{
  environment.systemPackages = [
    pkgs.claude-code
  ];

  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama-rocm;
    # rocmOverrideGfx = "10.3.0";
  };
}
