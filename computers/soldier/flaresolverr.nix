{ config, ... }: {
  services.flaresolverr = {
    enable = true;
  };

  services.nginx.virtualHosts."flaresolverr.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString config.services.flaresolverr.port}";
  };
}
