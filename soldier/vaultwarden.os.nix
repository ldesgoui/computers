{ withSystem, ... }:
{ config, lib, pkgs, ... }:
let
  cfg = config.services.vaultwarden.config;
  inherit (config.age) secrets;
in
{
  age.secrets = {
    vaultwarden-oidc-secret = {
      rekeyFile = ./vaultwarden-oidc-secret.age;
      generator.script = "alnum";
      owner = "kanidm";
      group = "kanidm";
    };

    vaultwarden-smtp-password = {
      rekeyFile = ./vaultwarden-smtp-password.age;
      generator.script = "alnum";
    };

    vaultwarden-installation-key = {
      rekeyFile = ./vaultwarden-installation-key.age;
    };

    vaultwarden-secrets = {
      rekeyFile = ./vaultwarden-secrets.age;
      owner = "vaultwarden";
      group = "vaultwarden";
      generator = {
        dependencies = [
          secrets.vaultwarden-oidc-secret
          secrets.vaultwarden-smtp-password
          secrets.vaultwarden-installation-key
        ];
        script = { decrypt, deps, ... }:
          lib.concatStringsSep "\n" (
            lib.zipListsWith (k: s: "printf '${k}=%s\n' $(${decrypt} ${lib.escapeShellArg s.file})")
              [
                "SSO_CLIENT_SECRET"
                "SMTP_PASSWORD"
                "PUSH_INSTALLATION_KEY"
              ]
              deps
          );
      };
    };
  };

  services.vaultwarden = {
    enable = true;

    package = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.vaultwarden-oidc);

    config = {
      ROCKET_ADDRESS = "::1";
      ROCKET_PORT = 8222;
      DOMAIN = "https://vaultwarden.int.lde.sg";

      WEB_VAULT_ENABLED = true;

      SSO_ENABLED = true;
      SSO_ONLY = true;
      SSO_AUTHORITY = "https://auth.lde.sg/oauth2/openid/vaultwarden";
      SSO_CLIENT_ID = "vaultwarden";

      SMTP_HOST = "localhost";
      SMTP_SECURITY = "force_tls";
      SMTP_PORT = 465;
      SMTP_FROM = "vaultwarden@lde.sg";
      SMTP_USERNAME = "vaultwarden";

      PUSH_ENABLED = true;
      PUSH_INSTALLATION_ID = "04108ee1-9978-4e67-b5f4-b27100e87777";
      PUSH_RELAY_URI = "https://api.bitwarden.eu";
      PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";

      SENDS_ALLOWED = false;
    };

    environmentFile = secrets.vaultwarden-secrets.path;
  };

  services.kanidm.provision = {
    groups = {
      vaultwarden_users.members = [ "ldesgoui" ];
    };

    systems.oauth2.vaultwarden = {
      originUrl = "https://vaultwarden.int.lde.sg/identity/connect/oidc-signin";
      originLanding = "https://vaultwarden.int.lde.sg";
      displayName = "Vaultwarden";
      scopeMaps.vaultwarden_users = [ "openid" "profile" "email" ];
      basicSecretFile = secrets.vaultwarden-oidc-secret.path;
    };
  };

  services.nginx.virtualHosts."vaultwarden.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString cfg.ROCKET_PORT}";
      proxyWebsockets = true;
    };
  };

  zfs.datasets.main._.enc._.services._.vaultwarden = {
    mountPoint = "/var/lib/vaultwarden"; # StateDirectory
  };
}
