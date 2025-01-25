_:
{ config, pkgs, ... }:
let
  extra_records =
    [
      { name = "scout.ts.lde.sg"; type = "AAAA"; value = "fd7a:115c:a1e0::deb9"; }
      { name = "soldier.ts.lde.sg"; type = "AAAA"; value = "fd7a:115c:a1e0::678b"; }
      { name = "demoman.ts.lde.sg"; type = "AAAA"; value = "fd7a:115c:a1e0::9383"; }
      { name = "engineer.ts.lde.sg"; type = "AAAA"; value = "fd7a:115c:a1e0::8c6f"; }
      { name = "spy.ts.lde.sg"; type = "AAAA"; value = "fd7a:115c:a1e0::1458"; }

      { name = "syncthing-scout.int.lde.sg"; type = "A"; value = "100.101.0.211"; }
      { name = "syncthing-scout.int.lde.sg"; type = "AAAA"; value = "fd7a:115c:a1e0::deb9"; }
    ] ++
    builtins.concatMap
      (name: [
        { name = "${name}.int.lde.sg"; type = "A"; value = "100.101.0.130"; }
        { name = "${name}.int.lde.sg"; type = "AAAA"; value = "fd7a:115c:a1e0::678b"; }
      ])
      [
        "jellyfin"
        "jellyseerr"
        "radarr"
        "sonarr"
        "lidarr"
        "bazarr"
        "prowlarr"
        "transmission"

        "mealie"
        "syncthing-soldier"
        "vikunja"

        "stalwart"
      ];
in
{
  age.secrets = {
    headscale-oidc-secret = {
      rekeyFile = ./headscale-oidc-secret.age;
      owner = "headscale";
      group = "headscale";
    };

    kanidm-headscale-oidc-secret = {
      rekeyFile = ./headscale-oidc-secret.age;
      owner = "kanidm";
      group = "kanidm";
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  services.headscale = {
    enable = true;
    port = 10443;

    settings = {
      server_url = "https://headscale.lde.sg";

      prefixes = {
        v4 = "100.101.0.0/24";
        v6 = "fd7a:115c:a1e0::/112";
        allocation = "random";
      };

      dns = {
        base_domain = "ts.lde.sg";
        inherit extra_records;
      };

      oidc = {
        issuer = "https://auth.lde.sg/oauth2/openid/headscale";
        client_id = "headscale";
        client_secret_path = config.age.secrets.headscale-oidc-secret.path;
      };

      policy.path = pkgs.writeText "policy.json" (builtins.toJSON {
        acls = [{
          action = "accept";
          src = [ "*" ];
          dst = [ "*:*" ];
        }];
      });
    };
  };

  services.kanidm.provision = {
    groups = {
      vpn_users.members = [ "ldesgoui" ];
    };

    systems.oauth2.headscale = {
      originUrl = "https://headscale.lde.sg/oidc/callback";
      originLanding = "https://headscale.lde.sg";
      displayName = "Headscale VPN";
      scopeMaps.vpn_users = [ "openid" "profile" "email" ];
      basicSecretFile = config.age.secrets.kanidm-headscale-oidc-secret.path;
      allowInsecureClientDisablePkce = true; # https://github.com/juanfont/headscale/pull/1812
    };
  };

  services.nginx.virtualHosts."headscale.lde.sg" = {
    listenAddresses = [ "0.0.0.0" "[::0]" ];
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };

  systemd.services.headscale = {
    after = [ "kanidm.service" ];
  };

  zfs.datasets = {
    main._.enc._.services = {
      _.headscale = {
        mountPoint = "/var/lib/headscale"; # StateDirectory
      };
    };
  };
}
