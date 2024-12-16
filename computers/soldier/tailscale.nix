{ config, pkgs, ... }: {
  age.secrets.headscale-oidc-secret = {
    rekeyFile = ./headscale-oidc-secret.age;
    owner = "headscale";
    group = "headscale";
  };

  security.acme.certs = {
    "ts.lde.sg" = {
      owner = "headscale";
      group = "headscale";
    };
  };

  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 10443;

    settings =
      let
        tld = "ts.lde.sg";
        certDir = config.security.acme.certs.${tld}.directory;
      in
      {
        server_url = "https://ts.lde.sg";

        prefixes.allocation = "random";

        dns = {
          base_domain = tld;
        };

        oidc = {
          issuer = "https://auth.lde.sg";
          client_id = "headscale";
          client_secret_path = config.age.secrets.headscale-oidc-secret.path;
          allowed_domains = [ "auth.lde.sg" ];
        };

        policy.path = pkgs.writeText "policy.json" (builtins.toJSON {
          acls = [ ];
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
