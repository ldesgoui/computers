_:
{ config, pkgs, ... }: {
  services.deluge = {
    enable = true;
    declarative = true;

    openFirewall = true;

    authFile = pkgs.writeText "" ''
      localclient:notsecure:10
    '';

    config = {
      random_port = false;
      listen_ports = [ 6880 6889 ];
      dht = false;
      upnp = false;
      natpmp = false;
      max_connections_global = -1;
      max_upload_slots_global = -1;
      max_connections_per_second = -1;
      max_active_seeding = -1;
      max_active_downloading = -1;
      max_active_limit = -1;
    };

    web.enable = true;
  };

  services.nginx.virtualHosts."deluge.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:${toString config.services.deluge.web.port}";
  };

  users.groups.deluge.members = [
    "radarr"
    "sonarr"
    "lidarr"
  ];

  zfs.datasets.main.enc.services.deluge = {
    mountPoint = config.services.deluge.dataDir;
  };
}
