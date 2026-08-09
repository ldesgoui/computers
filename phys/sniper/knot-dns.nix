{ config, ... }: {
  age.secrets.xfr-tsig = {
    rekeyFile = ./xfr-tsig.age;
    owner = "knot";
    generator.script = "knot-tsig";
    settings.id = "sniper.xfr.";
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.knot = {
    enable = true;

    keyFiles = [ config.age.secrets.xfr-tsig.path ];

    settings = {
      server = {
        listen = [
          # enp2s0
          "212.47.233.201"
          "127.0.0.1"
          "::"
        ];
      };

      remote = [{
        id = "primary";
        address = [ "2001:41d0:fc14:ca00:3e7c:3fff:fe22:bb0d" ];
        key = "sniper.xfr.";
      }];

      acl = [
        {
          id = "axfr-local";
          address = [ "127.0.0.1" "::1" ];
          action = "transfer";
        }
        {
          id = "notify-primary";
          key = [ "sniper.xfr." ];
          action = "notify";
        }
      ];

      template = [{
        id = "secondary";
        master = "primary";
        acl = [ "axfr-local" "notify-primary" ];
      }];

      zone = [{
        domain = "catalog.";
        template = "secondary";
        catalog-role = "interpret";
        catalog-template = "secondary";
      }];
    };
  };

  disko.devices.zpool.harvest.datasets = {
    "sniper/knot" = {
      type = "zfs_fs";
      mountpoint = "/var/lib/knot";
    };
  };
}
