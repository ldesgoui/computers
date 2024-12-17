{
  services.transmission = {
    enable = true;
    openPeerPorts = true;

    settings = {
      rpc-bind-address = "::1";
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = false;
    };
  };

  services.nginx.virtualHosts."transmission.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:9091";
  };

  systemd.services.transmission.serviceConfig.StateDirectoryMode = 770;

  users.groups.transmission.members = [
    "sonarr"
    "radarr"
    "lidarr"
    "bazarr"
  ];
}
