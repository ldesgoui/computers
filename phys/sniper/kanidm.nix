{ config, pkgs, ... }: {
  networking.firewall = {
    allowedTCPPorts = [ 8444 ];
  };

  networking.hosts = {
    "::1" = [ "auth.lde.sg" ]; # This is for the client
  };

  security.acme.certs."auth.lde.sg" = {
    group = "kanidm";
    reloadServices = [ "kanidm" ];
  };

  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning_1_11;

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
            origin = "repl://sniper.auth-repl.lde.sg:8444";
            bindaddress = "[::]:8444";

            # "repl://vm.auth-repl.lde.sg:8444" = {
            #   type = "mutual-pull";
            #   partner_cert = "";
            # };
          };
        };
    };
  };

  disko.devices.zpool.harvest.datasets = {
    "sniper/kanidm" = {
      type = "zfs_fs";
      mountpoint = "/var/lib/kanidm";
      options = {
        recordsize = "64K";
      };
    };
  };
}
