{ config, ... }: {
  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 443 ];
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ldesgoui@gmail.com";
      webroot = "/var/lib/acme/acme-challenge/";
    };
  };

  services.caddy = {
    enable = true;

    httpsPort = 10443;

    # For ACME
    virtualHosts = {
      "http://" = {
        extraConfig = ''
          handle /.well-known/acme-challenge/* {
            root * /var/lib/acme/acme-challenge/
            file_server
          }

          handle {
            redir https://{host}{uri}
          }
        '';
      };

      "https://lde.sg" = {
        extraConfig = ''
          file_server {
            root ${../../src/lde.sg}
          }
        '';
      };

      "https://ldesgoui.xyz" = {
        extraConfig = ''
          redir https://lde.sg{uri}
        '';
      };

      "piss-your.se" = {
        extraConfig = ''
          file_server {
            root ${../../src/piss-your.se}
          }
          redir / /f 301
        '';
      };
    };
  };

  services.haproxy = {
    enable = true;

    config = ''
      # global
        log /dev/log local0 debug
        maxconn 2048

      defaults
          log global
          timeout connect 5s
          timeout client 30s
          timeout server 30s
          timeout tunnel 4h

      frontend https
          bind :::443 v4v6
          mode tcp
          tcp-request inspect-delay 5s
          tcp-request content reject unless { req.ssl_hello_type 1 }
          use_backend be_kanidm if { var(req.ssl_sni) -m dom auth.lde.sg. }
          use_backend be_caddy

      backend be_kanidm
          mode tcp
          server kanidm ${config.services.kanidm.settings.bindaddress} send-proxy-v2

      backend be_caddy
          mode tcp
          tcp-request content set-dst var(txn.dst)
          server caddy [::1]:${config.services.caddy.httpsPort} send-proxy-v2
    '';
  };
}
