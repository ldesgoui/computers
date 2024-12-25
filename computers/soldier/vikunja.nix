{ config, ... }: {
  services.nginx.virtualHosts."vikunja.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString config.services.vikunja.port}";
  };

  services.vikunja = {
    enable = true;
    frontendScheme = "https";
    frontendHostname = "vikunja.int.lde.sg";
  };

  zfs.datasets.main._.enc._.services._.vikunja = {
    mountPoint = "/var/lib/private/vikunja"; # StateDirectory
  };
}
