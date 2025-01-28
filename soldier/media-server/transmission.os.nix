_:
{
  services.transmission = {
    enable = true;
    openPeerPorts = true;

    settings = {
      rpc-bind-address = "::1";
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = false;

      ratio-limit-enabled = true;
      ratio-limit = 0;
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

  zfs.datasets.main._.enc._.services._.transmission = {
    _.config = {
      mountPoint = "/var/lib/transmission/.config";
    };

    _.state = {
      mountPoint = "/var/lib/transmission"; # StateDirectory
    };
  };
}
