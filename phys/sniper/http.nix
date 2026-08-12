{ config, lib, ... }:
{
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

    globalConfig = ''
      email ldesgoui@gmail.com
      servers {
        listener_wrappers {
          proxy_protocol {
            allow ::1/128
          }
          tls
        }
      }
    '';

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

      "lde.sg" = {
        extraConfig = ''
          file_server {
            root ${../../src/lde.sg}
          }
        '';
      };

      "ldesgoui.xyz" = {
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
          option tcplog
          tcp-request inspect-delay 5s
          tcp-request content reject unless { req.ssl_hello_type 1 }
          use_backend be_kanidm if { req.ssl_sni -i -m str auth.lde.sg }
      ${lib.concatMapAttrsStringSep "\n" (site: _:
        if lib.hasPrefix "http://" site then
          "    # ignored: ${site}"
        else
          "    use_backend be_caddy if { req.ssl_sni -i -m str ${lib.removePrefix "https://" site} }"
      ) config.services.caddy.virtualHosts}
          use_backend be_stalwart

      backend be_kanidm
          mode tcp
          server kanidm ${config.services.kanidm.server.settings.bindaddress} send-proxy-v2

      backend be_caddy
          mode tcp
          server caddy [::1]:${toString config.services.caddy.httpsPort} send-proxy-v2

      backend be_stalwart
          mode tcp
          server stalwart [::1]:14443 send-proxy-v2
    '';
  };
}
