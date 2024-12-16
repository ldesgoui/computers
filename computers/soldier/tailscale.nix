{ config, pkgs, ... }: {
  age.secrets.headscale-oidc-secret = {
    rekeyFile = ./headscale-oidc-secret.age;
    owner = "headscale";
    group = "headscale";
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
          allowed_domains = [ "auth.lde.sg" ];
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

  services.tailscale = {
    enable = true;
  };

  zfs.datasets = {
    main._.enc._.services = {
      _.headscale = {
        mountPoint = "/var/lib/headscale"; # StateDirectory
      };
    };
  };
}
