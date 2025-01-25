_:
{ config, ... }: {
  age.secrets.dumbass-oidc-secret = {
    rekeyFile = ./dumbass-oidc-secret.age;
    generator.script = "alnum";
    owner = "kanidm";
    group = "kanidm";
  };

  services.kanidm.provision = {
    groups = {
      dumbass_admins.members = [ "ldesgoui" ];
      dumbass_users.members = [ "ldesgoui" ];
    };

    systems.oauth2.dumbass = {
      originUrl = "https://dumbass.int.lde.sg/auth/openid";
      originLanding = "https://dumbass.int.lde.sg";
      displayName = "dumbass";
      scopeMaps = {
        dumbass_admins = [ "openid" "profile" "email" ];
        dumbass_users = [ "openid" "profile" "email" ];
      };
      basicSecretFile = config.age.secrets.dumbass-oidc-secret.path;
      allowInsecureClientDisablePkce = true;
    };
  };

  services.headscale.settings.dns.extra_records = [
    { name = "dumbass.int.lde.sg"; type = "A"; value = "100.101.0.211"; }
    { name = "dumbass.int.lde.sg"; type = "AAAA"; value = "fd7a:115c:a1e0::deb9"; }
  ];
}
