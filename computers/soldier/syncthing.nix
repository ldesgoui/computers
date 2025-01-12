{ config, ... }: {
  services.nginx.virtualHosts."syncthing-soldier.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://${config.services.syncthing.guiAddress}";
    extraConfig = ''
      proxy_read_timeout 600s;
      proxy_send_timeout 600s;
    '';
  };

  services.syncthing = {
    enable = true;
    settings = {
      options = {
        listenAddresses = [
          "tcp://:22000"
          "quic://:22000"
        ];
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };

      gui.insecureSkipHostcheck = true;

      devices.scout = {
        id = "QZ6VFBQ-4QJLS2Y-R4IDJ7T-CKLYC7O-7GSTGO2-K2WBRWL-MGYZBV6-XZ6ZQQE";
        addresses = [ "tcp://scout.ts.lde.sg" "quic://scout.ts.lde.sg" ];
      };

      devices.spy = {
        id = "7PDDZFT-KCE7IKN-RMWIINY-26Q6GKP-KSBCOKQ-MCQIIYP-6WCQI7L-O55PFAT";
        addresses = [ "tcp://spy.ts.lde.sg" "quic://spy.ts.lde.sg" ];
      };

      folders.KeePass = {
        path = "/home/ldesgoui/.local/share/KeePass";
        devices = [ "scout" "spy" ];
        ignorePerms = true;
      };

      folders."Android Camera" = {
        id = "pixel_6_ukgq-photos";
        path = "/home/ldesgoui/Android Camera";
        devices = [ "spy" ];
        ignorePerms = true;
      };
    };
  };

  systemd.user.tmpfiles.users.ldesgoui.rules =
    map (path: "z '${path}' 02770 ldesgoui ldesgoui-syncthing - -") [
      config.services.syncthing.settings.folders.KeePass.path
      config.services.syncthing.settings.folders."Android Camera".path
    ];

  systemd.services.syncthing.serviceConfig = {
    UMask = "0002";
  };

  users.groups.ldesgoui-syncthing.members = [ "ldesgoui" "syncthing" ];

  zfs.datasets.main._.enc._.users._.ldesgoui = {
    _.android-camera = {
      mountPoint = config.services.syncthing.settings.folders."Android Camera".path;
    };

    _.keepass = {
      mountPoint = config.services.syncthing.settings.folders.KeePass.path;
    };
  };
}
