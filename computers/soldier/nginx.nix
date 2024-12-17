{
  services.nginx = {
    enable = true;

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;

    reversePreTls = {
      enable = true;
    };

    virtualHosts = {
      "0.0.0.0" = {
        default = true;
        rejectSSL = true;
        globalRedirect = "lde.sg";
      };
    };
  };
}
