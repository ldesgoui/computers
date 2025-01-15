{ config, ... }:
let
  acmeDir = config.security.acme.certs."mx1.lde.sg".directory;
in
{
  age.secrets = {
    stalwart-admin-secret = {
      rekeyFile = ./stalwart-admin-secret.age;
      generator.script = "passphrase";
      owner = "stalwart-mail";
      group = "stalwart-mail";
    };
  };

  security.acme.certs."mx1.lde.sg" = {
    group = "stalwart-mail";
    # TODO: reload
  };

  services.stalwart-mail = {
    enable = true;
    openFirewall = true;

    settings = {
      authentication = {
        fallback-admin = {
          user = "admin";
          secret = "{plain}%{file:${config.age.secrets.stalwart-admin-secret.path}}%";
        };

        master = {
          user = "master";
          secret = "{plain}%{file:${config.age.secrets.stalwart-admin-secret.path}}%";
        };
      };

      certificate."mx1.lde.sg" = {
        cert = "%{file:${acmeDir}/full.pem}%";
        private-key = "%{file:${acmeDir}/key.pem}%";
      };

      lookup = {
        default.hostname = "mx1.lde.sg";
      };

      queue.outbound = {
        hostname = "'soldier.wi.lde.sg'";
      };

      session.connect = {
        hostname = "'soldier.wi.lde.sg'";
      };

      server.listener = {
        management = {
          bind = [ "[::1]:5080" ];
          protocol = "http";
        };

        smtp = {
          bind = [ "[::]:25" ];
          protocol = "smtp";
        };

        submissions = {
          bind = [ "[::]:465" ];
          protocol = "smtp";
          tls.implicit = true;
        };

        imaptls = {
          bind = [ "[::]:993" ];
          protocol = "imap";
          tls.implicit = true;
        };
      };

      server.http = {
        use-x-forwarded = true;
      };
    };
  };

  services.nginx.virtualHosts."stalwart.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:5080";
  };
}
