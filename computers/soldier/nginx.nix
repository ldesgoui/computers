{
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
        default = true;
        rejectSSL = true;
        globalRedirect = "lde.sg";
      };
    };
  };
}
