{ config, ... }:
let
  acmeDir = config.security.acme.certs."mx.piss-your.se".directory;
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

  security.acme.certs."mx.piss-your.se" = {
    group = "stalwart-mail";
  };

  services.stalwart-mail = {
    enable = true;
    openFirewall = true;

    settings = {
      authentication.fallback-admin = {
        user = "admin";
        secret = "{plain}%{file:${config.age.secrets.stalwart-admin-secret.path}}%";
      };

      certificate."mx.piss-your.se" = {
        cert = "%{file:${acmeDir}/full.pem}%";
        private-key = "%{file:${acmeDir}/key.pem}%";
      };

      lookup = {
        default.hostname = "mx.piss-your.se";
      };

      server.listener = {
        management = {
          bind = [ "[::1]:5080" ];
          protocol = "http";
        };

        smtp = {
          bind = [ "0.0.0.0:25" "[::0]:25" ];
          protocol = "smtp";
        };

        submissions = {
          bind = [ "0.0.0.0:465" "[::0]:465" ];
          protocol = "smtp";
          tls.implicit = true;
        };

        imaptls = {
          bind = [ "0.0.0.0:993" "[::0]:993" ];
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
