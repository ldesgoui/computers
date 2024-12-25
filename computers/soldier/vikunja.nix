{ config, ... }: {
  age.secrets = {
    kanidm-vikunja-oidc-secret = {
      rekeyFile = ./vikunja-oidc-secret.age;
      generator.script = "alnum";
      owner = "kanidm";
      group = "kanidm";
    };

    vikunja-oidc-secret = {
      rekeyFile = ./vikunja-oidc-secret-env.age;
      generator = {
        dependencies = [ config.age.secrets.kanidm-vikunja-oidc-secret ];
        script = { lib, decrypt, deps, ... }: ''
          ${decrypt} ${lib.escapeShellArg (builtins.head deps).file} \
            | xargs printf 'VIKUNJA_AUTH_OPENID_PROVIDERS_KANIDM_CLIENTSECRET=%s\n'
        '';
      };
    };
  };

  services.kanidm.provision.systems.oauth2.vikunja = {
    originUrl = "https://vikunja.int.lde.sg/auth/openid/";
    originLanding = "https://vikunja.int.lde.sg";
    displayName = "Vikunja";
    scopeMaps.vikunja_users = [ "openid" "profile" "email" ];
    basicSecretFile = config.age.secrets.kanidm-vikunja-oidc-secret.path;
  };

  services.nginx.virtualHosts."vikunja.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString config.services.vikunja.port}";
  };

  services.vikunja = {
    enable = true;
    frontendScheme = "https";
    frontendHostname = "vikunja.int.lde.sg";

    settings = {
      service = {
        enablecaldav = false;
        enabletotp = false;
        enableemailreminders = false;
      };

      backgrounds.enabled = false;

      auth.local.enabled = false;

      auth.openid = {
        enabled = true;
        providers.kanidm = {
          name = "Kanidm";
          authurl = "https://auth.lde.sg/oauth2/openid/vikunja";
          clientid = "vikunja";
        };
      };
    };

    environmentFiles = [ config.age.secrets.vikunja-oidc-secret.path ];
  };

  zfs.datasets.main._.enc._.services._.vikunja = {
    mountPoint = "/var/lib/private/vikunja"; # StateDirectory
  };
}
