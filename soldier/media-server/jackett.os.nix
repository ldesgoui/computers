{ inputs, withSystem, ... }:
{ config, pkgs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) config system; };
in
{
  services.jackett = {
    enable = true;
    # package = pkgs-unstable.jackett;
    package = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.jackett);
  };

  services.nginx.virtualHosts."jackett.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString config.services.jackett.port}";
  };

  zfs.datasets.main.enc.services.jackett = {
    mountPoint = "/var/lib/jackett";
  };
}
