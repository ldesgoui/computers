{ inputs, ... }:
{ pkgs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) config;
    inherit (pkgs.stdenv.hostPlatform) system;
  };
in
{
  services.flaresolverr = {
    enable = true;
    package = pkgs-unstable.flaresolverr;
  };
}
