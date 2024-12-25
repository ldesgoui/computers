{ config, ... }: {
  services.nginx.virtualHosts."vikunja.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${config.services.vikunja.port}";
  };

  services.vinkunja = {
    enable = true;
    frontendScheme = "https";
    frontendHostname = "vikunja.int.lde.sg";
  };

  zfs.datasets.main._.enc._.services._.vikunja = {
    mountPoint = "/var/lib/vikunja"; # StateDirectory
  };
}
