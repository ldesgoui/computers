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

      persons.ldesgoui = {
        displayName = "Lucas";
        mailAddresses = [ "ldesgoui@gmail.com" ];
        groups = [ ];
      };

      groups.media_viewers.members = [ "ldesgoui" ];

      systems.oauth2.jellyfin = {
        originUrl = "https://jf.ldesgoui.xyz/sso/OID/redirect/kanidm";
        originLanding = "https://jf.ldesgoui.xyz";
        displayName = "Jellyfin";
        preferShortUsername = true;
        scopeMaps.media_viewers = [ "openid" "profile" ];
      };

      systems.oauth2.jellyseerr = {
        originUrl = "https://js.ldesgoui.xyz";
        originLanding = "https://js.ldesgoui.xyz";
        displayName = "Jellyseerr";
        preferShortUsername = true;
        scopeMaps.media_viewers = [ "openid" "profile" ];
      };
    };
  };
}
