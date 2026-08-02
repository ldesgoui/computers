{ inputs, ... }:
{ pkgs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) config;
    inherit (pkgs.stdenv.hostPlatform) system;
  };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox.override {
      cfg.speechSynthesisSupport = false;
    };
  };
}
