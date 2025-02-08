_:
{ pkgs, ... }: {
  services.transmission = {
    enable = true;
    openPeerPorts = true;

    package = pkgs.transmission_4;

    settings = {
      rpc-bind-address = "::1";
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = false;

      message-level = 4;

      cache-size-mb = 128;
      download-queue-size = 10;
      peer-limit-global = 5000;
      upload-slots-per-torrent = 50;
    };
  };

  services.nginx.virtualHosts."transmission.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:9091";
  };

  systemd.services.transmission.serviceConfig.StateDirectoryMode = 770;

  systemd.tmpfiles.settings."20-transmission" = {
    "/var/lib/transmission/.config" = {
      z = {
        mode = "0700";
        user = "transmission";
        group = "transmission";
      };
    };
  };


  users.groups.transmission.members = [
    "sonarr"
    "radarr"
    "lidarr"
  ];

  zfs.datasets.main.enc.services.transmission = {
    config = {
      mountPoint = "/var/lib/transmission/.config";
    };

    state = {
      mountPoint = "/var/lib/transmission"; # StateDirectory
    };
  };
}
