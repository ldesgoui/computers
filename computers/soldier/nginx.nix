{ config, ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;

    defaultListenAddresses = [
      "127.0.0.1"
      "[::1]"
      "100.101.0.130"
      "[fd7a:115c:a1e0::678b]"
    ];

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;

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
