_:
{
  services.nginx = {
    virtualHosts."acted-wtf-temporary-for-northernlion.lde.sg" = {
      listenAddresses = [ "0.0.0.0" "[::0]" ];
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      locations."/" = {
        proxyPass = "https://cloudflare.com";
        recommendedProxySettings = false;
        extraConfig = ''
          proxy_set_header Host acted.wtf;
          proxy_ssl_verify on;
          proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
          proxy_ssl_name acted.wtf;
          proxy_ssl_server_name on;
        '';
      };

      locations."= /static/js/main.b1d1072d.js" = {
        root = ./acted-wtf-temporary-for-northernlion;
      };

      locations."/api" = {
        proxyPass = "https://acted-server-new.onrender.com";
        recommendedProxySettings = false;
        extraConfig = ''
          proxy_set_header Host acted-server-new.onrender.com;
          proxy_ssl_verify on;
          proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
          proxy_ssl_name acted-server-new.onrender.com;
          proxy_ssl_server_name on;
        '';
      };
    };
  };
}

