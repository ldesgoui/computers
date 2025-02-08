_:
{ config, ... }: {
  services.thelounge = {
    enable = true;
    port = 9020;
    extraConfig = {
      reverseProxy = true;
      leaveMessage = "giga";
    };
  };

  services.nginx.virtualHosts."thelounge.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString config.services.thelounge.port}";
  };

  zfs.datasets.main.enc.services.thelounge = {
    mountPoint = "/var/lib/thelounge"; # StateDirectory
  };
}
