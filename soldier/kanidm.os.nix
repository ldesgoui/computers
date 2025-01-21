_:
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
    group = "acme-cert-auth";
    reloadServices = [ "kanidm" ];
  };

  services.kanidm = {
    enableServer = true;
    package = pkgs.kanidm.withSecretProvisioning;

    serverSettings = {
      inherit domain;
      origin = "https://${domain}";

      trust_x_forward_for = true;

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
        vpn_users.members = [ "ldesgoui" ];

        media_admins.members = [ "ldesgoui" ];
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
        media_listeners.members = [ "ldesgoui" ];

        mealie_admins.members = [ "ldesgoui" ];
        mealie_users.members = [ "ldesgoui" ];

        vikunja_users.members = [ "ldesgoui" ];
      };
    };
  };

  services.nginx.virtualHosts."${domain}" = {
    listenAddresses = [ "0.0.0.0" "[::0]" ];
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://${config.services.kanidm.serverSettings.bindaddress}";
      extraConfig = ''
        proxy_ssl_verify on;
        proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
        proxy_ssl_name ${domain};
      '';
    };
  };

  users.groups.acme-cert-auth.members = [ "nginx" "kanidm" ];
}
