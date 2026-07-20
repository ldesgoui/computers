_: {

  services.nginx.virtualHosts."fantasy.tf2.spot" = {
    listen = import ../nginx-listen.nix;
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:4242";
    };
  };
}
