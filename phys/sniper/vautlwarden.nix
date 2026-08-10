{ config, ... }: {

  age.secrets.vaultwarden-oidc-secret = {
    rekeyFile = ./vaultwarden-oidc-secret.age;
    generator.script = "alnum";
  };

  age.secrets.vaultwarden-smtp-password = {
    rekeyFile = ./vaultwarden-smtp-password.age;
    generator.script = "alnum";
  };

  age.secrets.vaultwarden-installation-key = {
    rekeyFile = ./vaultwarden-installation-key.age;
  };

  age.secrets.vaultwarden-env = {
    rekeyFile = ./vaultwarden-env.age;
    generator = {
      dependencies = {
        SSO_CLIENT_SECRET = config.age.secrets.vaultwarden-oidc-secret;
        SMTP_PASSWORD = config.age.secrets.vaultwarden-smtp-password;
        PUSH_INSTALLATION_KEY = config.age.secrets.vaultwarden-installation-key;
      };
      script = "deps-to-env";
    };
  };

  services.caddy = {
    virtualHosts = {
      "passwords.lde.sg" = {
        extraConfig = ''
          reverse_proxy [::1]:${toString config.services.vaultwarden.config.ROCKET_PORT} {
            header_up X-Real-IP {remote_host}
          }
        '';
      };
    };
  };

  services.vaultwarden = {
    enable = true;

    config = {
      ROCKET_ADDRESS = "::1";
      ROCKET_PORT = 8222;

      DATABASE_URL = "/var/lib/vaultwarden/db/vaultwarden.sqlite3";
      ICON_CACHE_FOLDER = "/var/cache/vaultwarden/icon-cache";
      TMP_FOLDER = "/tmp/vaultwarden"; # PrivateTmp is already set

      DOMAIN = "https://passwords.lde.sg";

      WEB_VAULT_ENABLED = true;

      SIGNUPS_ALLOWED = false;

      # SSO_ENABLED = true;
      # SSO_ONLY = true;
      # SSO_AUTHORITY = "https://auth.lde.sg/oauth2/openid/vaultwarden";
      # SSO_CLIENT_ID = "vaultwarden";

      SMTP_HOST = "mx1.lde.sg";
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

    environmentFile = config.age.secrets.vaultwarden-env.path;
  };

  systemd.services.vaultwarden = {
    serviceConfig = {
      CacheDirectory = "vaultwarden";
      CacheDirectoryMode = "0700";
    };
  };

  disko.devices.zpool.harvest.datasets = {
    "sniper/vaultwarden" = {
      type = "zfs_fs";
      mountpoint = "/var/lib/vaultwarden";
    };

    "sniper/vaultwarden/db" = {
      type = "zfs_fs";
      mountpoint = "/var/lib/vaultwarden/db";
      options = {
        recordsize = "64K";
      };
    };
  };
}
