_: {

  services.nginx.virtualHosts."fantasy.tf2.spot" = {
    listen = import ../nginx-listen.nix;
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://[fd4c:a29e:23d9:0:c4e8:b0b9:b2e9:2d68]";
      extraConfig = ''
        proxy_ssl_verify on;
        proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
        proxy_ssl_name fantasy.tf2.spot;
      '';
    };
  };
}
