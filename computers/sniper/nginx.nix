{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;

    defaultListenAddresses = [
      "127.0.0.1"
      "[::1]"
      # "100.101.0.?"
      # "[fd7a:115c:a1e0::?]"
    ];

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;

    virtualHosts = {
      "0.0.0.0" = {
        listenAddresses = [ "0.0.0.0" "[::0]" ];
        default = true;
        rejectSSL = true;
        globalRedirect = "lde.sg";
      };
    };
  };
}
