_:
{ config, lib, ... }: {
  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
  };

  services.nginx = {
    defaultListenAddresses = [
      "127.0.0.1"
      "[::1]"
    ];

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;

    resolver.addresses = lib.mkIf config.services.tailscale.enabled [ "100.100.100.100" ];

    virtualHosts = {
      "0.0.0.0" = {
        # Whenever we add new cases, they need to end up here
        # in order for `default` to work as intended.
        listenAddresses = [ "0.0.0.0" "[::0]" ]
          ++ config.services.nginx.defaultListenAddresses;
        default = true;
        rejectSSL = true;
        globalRedirect = "lde.sg";
      };
    };
  };
}
