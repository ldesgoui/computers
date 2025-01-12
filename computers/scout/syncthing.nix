{ config, ... }: {
  services.nginx.virtualHosts."syncthing-scout.int.lde.sg" = {
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

      devices.soldier = {
        id = "KOQVGTB-VDMTHL7-IV6EN45-2TGWPGW-NYYNMVF-YCLWRPD-CXEIM6C-6TWUKAL";
        addresses = [
          "tcp://soldier.ts.lde.sg"
          "quic://soldier.ts.lde.sg"
        ];
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
        devices = [ "soldier" "spy" ];
        ignorePerms = true;
      };
    };
  };

  systemd.user.tmpfiles.users.ldesgoui.rules =
    map (path: "z '${path}' 02770 ldesgoui ldesgoui-syncthing - -") [
      config.services.syncthing.settings.folders.KeePass.path
    ];

  systemd.services.syncthing.serviceConfig = {
    UMask = "0002";
  };

  users.groups.ldesgoui-syncthing.members = [ "ldesgoui" "syncthing" ];

  zfs.datasets.main._.enc._.users._.ldesgoui = {
    _.keepass = {
      mountPoint = config.services.syncthing.settings.folders.KeePass.path;
    };
  };
}
