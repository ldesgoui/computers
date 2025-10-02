{ inputs, ... }:
{ pkgs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) config system; };
in
{
  services.prowlarr = {
    enable = true;
    package = pkgs-unstable.prowlarr;
  };

  services.nginx.virtualHosts."prowlarr.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:9696";
  };

  zfs.datasets.main.enc.services.prowlarr = {
    mountPoint = "/var/lib/private/prowlarr"; # StateDirectory
  };
}
