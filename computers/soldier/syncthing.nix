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
        path = "/home/ldesgoui/Android Camera";
        devices = [ "spy" ];
      };
    };
  };

  systemd.tmpfiles.settings."20-ldesgoui-syncthing" =
    let
      z = mode: user: group: { z = { inherit mode user group; }; };
    in
    {
      ${config.services.syncthing.settings.folders.KeePass.path} = z "0770" "ldesgoui" "syncthing";
      ${config.services.syncthing.settings.folders."Android Camera".path} = z "0770" "ldesgoui" "syncthing";
    };

  zfs.datasets.main._.enc._.users._.ldesgoui = {
    _.android-camera = {
      mountPoint = config.services.syncthing.settings.folders."Android Camera".path;
    };

    _.keepass = {
      mountPoint = config.services.syncthing.settings.folders.KeePass.path;
    };
  };
}
