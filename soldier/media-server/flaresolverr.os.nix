{ inputs, ... }:
{ pkgs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) config system; };
in
{
  services.flaresolverr = {
    enable = true;
    package = pkgs-unstable.flaresolverr;
  };
}
