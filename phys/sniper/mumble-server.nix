{ config, ... }: {
  age.secrets.mumble-server-password = {
    rekeyFile = ./mumble-server-password.age;
  };

  age.secrets.mumble-server-env = {
    rekeyFile = ./mumble-server-env.age;
    generator = {
      dependencies = { PASSWORD = config.age.secrets.mumble-server-password; };
      script = "deps-to-env";
    };
  };

  security.acme.certs."cool-zone.lde.sg" = {
    extraDomainNames = [
      "sniper.wi.lde.sg"
      "mumble.ldesgoui.xyz"
    ];

    group = "murmur";
    reloadServices = [ "murmur" ];
  };

  services.murmur = {
    enable = true;

    environmentFile = config.age.secrets.mumble-server-env.path;
    tls.useACMEHost = "cool-zone.lde.sg";

    openFirewall = true;

    registerName = "epic server of cool";

    bandwidth = 558000;
    imgMsgLength = 1024 * 1024 * 10;

    password = "$PASSWORD";

    welcometext = builtins.replaceStrings [ "\n" ] [ "<br />" ] ''
      hi
    '';

    extraConfig = ''
      rememberchannelduration=3600
    '';
  };

  systemd.services.murmur.reload = "kill -USR1 $MAINPID";

  disko.devices.zpool.harvest.datasets = {
    "sniper/mumble-server" = {
      type = "zfs_fs";
      mountpoint = "/var/lib/murmur";
      options = {
        recordsize = "64K";
      };
    };
  };
}
