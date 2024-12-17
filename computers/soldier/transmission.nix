{
  services.transmission = {
    enable = true;
    openPeerPorts = true;

    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = false;
    };
  };

  systemd.services.transmission.serviceConfig.StateDirectoryMode = 770;

  users.groups.transmission.members = [
    "sonarr"
    "radarr"
    "lidarr"
    "bazarr"
  ];
}
