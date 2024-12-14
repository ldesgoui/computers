{ config, ... }:
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

    serverSettings = {
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
      };
    };
  };
}
