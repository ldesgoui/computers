{ config, pkgs, inputs, ... }: {
  services.flaresolverr = {
    enable = true;
    # TODO: when flaresolverr is fixed (xdd)
    package = inputs.nur-xddxdd.packages.${pkgs.stdenv.hostPlatform.system}.flaresolverr-21hsmw;
  };

  services.nginx.virtualHosts."flaresolverr.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString config.services.flaresolverr.port}";
  };
}
