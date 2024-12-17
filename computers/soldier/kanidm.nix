{ config, pkgs, ... }:
let
  domain = "auth.lde.sg";
  certDir = config.security.acme.certs."${domain}".directory;
in
{
  age.secrets = {
    kanidm-admin-password = {
      rekeyFile = ./kanidm-admin-password.age;
      owner = "kanidm";
      group = "kanidm";
    };

    kanidm-idm-admin-password = {
      rekeyFile = ./kanidm-idm-admin-password.age;
      owner = "kanidm";
      group = "kanidm";
    };
  };

  environment.systemPackages = [ config.services.kanidm.package ];

  security.acme.certs."${domain}" = {
    group = "kanidm";
    reloadServices = [ "kanidm" ];
  };

  services.kanidm = {
    enableServer = true;
    package = pkgs.kanidm.withSecretProvisioning;

    serverSettings = {
      bindaddress = "0.0.0.0:8443";

      inherit domain;
      origin = "https://${domain}";

      tls_key = "${certDir}/key.pem";
      tls_chain = "${certDir}/full.pem";
    };

    provision = {
      enable = true;
      adminPasswordFile = config.age.secrets.kanidm-admin-password.path;
      idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin-password.path;

      persons = {
        ldesgoui = {
          displayName = "Lucas";
          mailAddresses = [ "ldesgoui@gmail.com" ];
          groups = [ ];
        };

        eepily.displayName = "Eepily";
        gubbins.displayName = "Gubbins";
        lux.displayName = "Lux";
        mac.displayName = "Mac";
        squirrel.displayName = "Squirrel";

        mira.displayName = "Mira";
        smarmy.displayName = "Smarmy";
        spacesloth.displayName = "Spacesloth";
      };

      groups = {
        media_viewers.members = [
          "ldesgoui"

          "eepily"
          "gubbins"
          "lux"
          "mac"
          "squirrel"

          "mira"
          "smarmy"
          "spacesloth"
        ];

        vpn_users.members = [ "ldesgoui" ];
      };
    };
  };

  services.nginx.reversePreTls.names = {
    "auth.lde.sg" = "${config.services.kanidm.serverSettings.bindaddress}";
  };
}
