{ config, pkgs, ... }: {
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

  security.acme.certs = {
    "headscale.lde.sg" = {
      group = "headscale";
      reloadServices = [ "headscale" ];
    };
  };

  services.headscale = {
    enable = true;
    port = 10443;

    settings =
      let
        certDir = config.security.acme.certs."headscale.lde.sg".directory;
      in
      {
        server_url = "https://headscale.lde.sg";

        prefixes.allocation = "random";

        dns = {
          base_domain = "ts.lde.sg";
          extra_records =
            let
              names =
                [
                  # "auth.lde.sg"
                  # "headscale.lde.sg"
                  "jellyfin.int.lde.sg"
                  "jellyseerr.int.lde.sg"
                  "radarr.int.lde.sg"
                  "sonarr.int.lde.sg"
                  "lidarr.int.lde.sg"
                  "bazarr.int.lde.sg"
                  "prowlarr.int.lde.sg"
                  "transmission.int.lde.sg"
                  "syncthing-soldier.int.lde.sg"
                  "vikunja.int.lde.sg"
                ];
            in
            map
              (name: {
                inherit name;
                type = "A";
                value = "100.66.64.80";
              })
              names
            ++ map
              (name: {
                inherit name;
                type = "AAAA";
                value = "fd7a:115c:a1e0:35a3:dbd4:a204:2569:f4a0";
              })
              names;
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

        tls_cert_path = "${certDir}/cert.pem";
        tls_key_path = "${certDir}/key.pem";
      };
  };

  # TODO: re-enable PKCE
  # https://github.com/juanfont/headscale/pull/1812
  services.kanidm.provision.systems.oauth2. headscale = {
    originUrl = "https://headscale.lde.sg/oidc/callback";
    originLanding = "https://headscale.lde.sg";
    displayName = "Headscale VPN";
    scopeMaps.vpn_users = [ "openid" "profile" "email" ];
    basicSecretFile = config.age.secrets.kanidm-headscale-oidc-secret.path;
  };

  services.nginx.reversePreTls.names = {
    "headscale.lde.sg" = "127.0.0.1:${toString config.services.headscale.port}";
  };

  zfs.datasets = {
    main._.enc._.services = {
      _.headscale = {
        mountPoint = "/var/lib/headscale"; # StateDirectory
      };
    };
  };
}
