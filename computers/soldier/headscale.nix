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
    };
  };

  services.headscale = {
    enable = true;
    address = "0.0.0.0";
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
    "headscale.lde.sg" = "localhost:${toString config.services.headscale.port}";
  };

  zfs.datasets = {
    main._.enc._.services = {
      _.headscale = {
        mountPoint = "/var/lib/headscale"; # StateDirectory
      };
    };
  };
}
