_: {
  users.users.ldesgoui = {
    extraGroups = [ "podman" ];
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };


  services.nginx.virtualHosts."mathesar.tf2.spot" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:8080";
  };
}
