{ config, ... }: {
  services.nginx.virtualHosts."syncthing-soldier.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://${config.services.syncthing.guiAddress}";
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

      devices.spy = {
        id = "7PDDZFT-KCE7IKN-RMWIINY-26Q6GKP-KSBCOKQ-MCQIIYP-6WCQI7L-O55PFAT";
        addresses = [
          "tcp://spy.ts.lde.sg"
          "quic://spy.ts.lde.sg"
        ];
      };

      folders.KeePass = {
        path = "/home/ldesgoui/.local/share/KeePass";
        devices = [ "spy" ];
      };

      folders."Android Camera" = {
        id = "pixel_6_ukgq-photos";
        path = "/home/ldesgoui/Android Camera";
        devices = [ "spy" ];
      };
    };
  };

  systemd.user.tmpfiles.users.ldesgoui.rules =
    map (path: "z ${path} 0770 ldesgoui syncthing - -") [
      config.services.syncthing.settings.folders.KeePass.path
      config.services.syncthing.settings.folders."Android Camera".path
    ];

  zfs.datasets.main._.enc._.users._.ldesgoui = {
    _.android-camera = {
      mountPoint = config.services.syncthing.settings.folders."Android Camera".path;
    };

    _.keepass = {
      mountPoint = config.services.syncthing.settings.folders.KeePass.path;
    };
  };
}
