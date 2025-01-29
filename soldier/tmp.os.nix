_:
{
  services.nginx = {
    virtualHosts."acted-wtf-temporary-for-northernlion.lde.sg" = {
      listenAddresses = [ "0.0.0.0" "[::0]" ];
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      locations."/" = {
        proxyPass = "https://104.21.66.254";
        recommendedProxySettings = false;
        extraConfig = ''
          proxy_set_header Host acted.wtf;
          proxy_ssl_verify off;
          proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
          proxy_ssl_name acted.wtf;
        '';
      };
    };
  };
}

