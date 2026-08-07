{ config, ... }: {
  age.secrets.xfr-tsig = {
    rekeyFile = ./xfr-tsig.age;
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
        automatic-acl = "on";
      };

      remote = [{
        id = "primary";
        address = [ "ns1.piss-your.se" ];
        key = "sniper.xfr.";
      }];

      template = [{
        id = "secondary";
        master = "primary";
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
