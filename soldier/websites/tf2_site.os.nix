_:
{
  services.nginx = {
    virtualHosts."tf2.site" = {
      listenAddresses = [ "0.0.0.0" "[::0]" ];
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      root = ./tf2.site;
    };
  };
}
