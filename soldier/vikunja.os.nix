_:
{ config, pkgs, ... }:
let
  cfg = config.services.vikunja;
  format = pkgs.formats.json { };
  configFile = format.generate "config.json" cfg.settings;
in
{
  age.secrets = {
    kanidm-vikunja-oidc-secret = {
      rekeyFile = ./vikunja-oidc-secret.age;
      generator.script = "alnum";
      owner = "kanidm";
      group = "kanidm";
    };

    vikunja-config = {
      rekeyFile = ./vikunja-config.age;
      generator = {
        dependencies = [ config.age.secrets.kanidm-vikunja-oidc-secret ];
        script = { lib, decrypt, deps, ... }: ''
          ${decrypt} ${lib.escapeShellArg (builtins.head deps).file} \
          | xargs ${lib.getExe pkgs.jq} '.auth.openid.providers[0].clientsecret = $secret' ${configFile} --arg secret
        '';
      };
    };
  };

  environment.etc."vikunja/config.yaml".enable = false;

  services.kanidm.provision.systems.oauth2.vikunja = {
    originUrl = "https://vikunja.int.lde.sg/auth/openid/kanidm";
    originLanding = "https://vikunja.int.lde.sg";
    displayName = "Vikunja";
    scopeMaps.vikunja_users = [ "openid" "profile" "email" ];
    basicSecretFile = config.age.secrets.kanidm-vikunja-oidc-secret.path;
    allowInsecureClientDisablePkce = true;
  };

  services.nginx.virtualHosts."vikunja.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString config.services.vikunja.port}";
  };

  services.vikunja = {
    enable = true;

    frontendScheme = "https"; # Outdated but necessary
    frontendHostname = "vikunja.int.lde.sg"; # Outdated but necessary

    settings = {
      service = {
        publicurl = "https://vikunja.int.lde.sg";
        enablecaldav = false;
        enabletotp = false;
        enableemailreminders = false;
      };

      backgrounds.enabled = false;

      auth.local.enabled = false;

      auth.openid = {
        enabled = true;
        providers = [{
          name = "Kanidm";
          authurl = "https://auth.lde.sg/oauth2/openid/vikunja";
          clientid = "vikunja";
        }];
      };
    };
  };

  systemd.services.vikunja = {
    environment.HOME = "/var/lib/vikunja";
    serviceConfig.LoadCredential = [ "config:${config.age.secrets.vikunja-config.path}" ];
    preStart = ''
      mkdir -p "$HOME/.config/vikunja"
      cp -f "$CREDENTIALS_DIRECTORY/config" "$HOME/.config/vikunja/config.json";
    '';
  };

  zfs.datasets.main._.enc._.services._.vikunja = {
    mountPoint = "/var/lib/private/vikunja"; # StateDirectory
  };
}
