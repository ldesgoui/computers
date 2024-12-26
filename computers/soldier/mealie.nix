{ config, pkgs, inputs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) config system; };
in
{
  age.secrets = {
    kanidm-mealie-oidc-secret = {
      rekeyFile = ./mealie-oidc-secret.age;
      generator.script = "alnum";
      owner = "kanidm";
      group = "kanidm";
    };

    mealie-secrets = {
      rekeyFile = ./mealie-secrets.age;
      generator = {
        dependencies = [ config.age.secrets.kanidm-mealie-oidc-secret ];
        script = { lib, decrypt, deps, ... }: ''
          ${decrypt} ${lib.escapeShellArg (builtins.head deps).file} \
          | xargs printf 'OIDC_CLIENT_SECRET=%s\n'
        '';
      };
    };
  };

  services.kanidm.provision.systems.oauth2.mealie = {
    originUrl = "https://mealie.int.lde.sg/login";
    originLanding = "https://mealie.int.lde.sg";
    displayName = "Mealie";
    preferShortUsername = true;
    scopeMaps = {
      mealie_admins = [ "openid" "profile" "email" "groups" ];
      mealie_users = [ "openid" "profile" "email" "groups" ];
    };
    basicSecretFile = config.age.secrets.kanidm-mealie-oidc-secret.path;
  };

  services.nginx.virtualHosts."mealie.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}";
  };

  services.mealie = {
    enable = true;
    package = pkgs-unstable.mealie;

    settings = {
      TZ = "Europe/Paris";
      OIDC_AUTH_ENABLED = "True";
      OIDC_CONFIGURATION_URL = "https://auth.lde.sg/oauth2/openid/mealie/.well-known/openid-configuration";
      OIDC_CLIENT_ID = "mealie";
      OIDC_ADMIN_GROUP = "mealie_admins@auth.lde.sg";
      OIDC_AUTO_REDIRECT = "True";
      OIDC_PROVIDER_NAME = "Kanidm";
    };

    credentialsFile = config.age.secrets.mealie-secrets.path;
  };

  zfs.datasets.main._.enc._.services._.mealie = {
    mountPoint = "/var/lib/private/mealie"; # StateDirectory
  };
}
