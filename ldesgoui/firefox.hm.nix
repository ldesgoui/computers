{ inputs, ... }:
{ pkgs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) config system; };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;
  };
}
