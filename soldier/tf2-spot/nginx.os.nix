_: {

  services.nginx.virtualHosts."fantasy.tf2.spot" = {
    listenAddresses = [ "0.0.0.0" "[::0]" ];
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:4242";
    };
  };
}
