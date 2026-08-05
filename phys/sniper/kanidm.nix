{ config, pkgs, ... }: {
  age.secrets.wg20-privkey = {
    rekeyFile = ./wg20.age;
    owner = "systemd-network";
    group = "systemd-network";
    mode = "640";
    generator.script = "wg-pair";
  };

  networking.hosts = {
    "::1" = [ "auth.lde.sg" ]; # This is for the client
  };

  security.acme.certs."auth.lde.sg" = {
    group = "kanidm";
    reloadServices = [ "kanidm" ];
  };

  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning_1_10;

    client = {
      enable = true;
      settings = {
        uri = "https://auth.lde.sg";
      };
    };

    server = {
      enable = true;
      settings =
        let
          certDir = config.security.acme.certs."auth.lde.sg".directory;
        in
        {
          bindaddress = "[::1]:12443";

          domain = "auth.lde.sg";
          origin = "https://auth.lde.sg";

          tls_key = "${certDir}/key.pem";
          tls_chain = "${certDir}/full.pem";

          db_fs_type = "zfs";

          http_client_address_info.proxy-v2 = [
            "::1/128"
          ];

          replication = {
            origin = "repl://[fd20::2]:20444";
            bindaddress = "[fd20::2]:20444";

            # "repl://[fd20::1]:20444" = {
            #   type = "mutual-pull";
            #   partner_cert = "";
            # };
          };
        };
    };
  };

  systemd.network = {
    networks."50-wg20" = {
      matchConfig.Name = "wg20";
      address = [ "fd20::2/128" ];
    };

    netdevs."50-wg20" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg20";
      };

      wireguardConfig = {
        ListenPort = 51820;
        PrivateKeyFile = config.age.secrets.wg20-privkey.path;
        RouteTable = "main";
      };

      wireguardPeers = [{
        PublicKey = builtins.readFile ./../../virt/kanidm/wg20.pub;
        AllowedIPs = [ "fd20::1/128" ];
      }];
    };
  };

}
