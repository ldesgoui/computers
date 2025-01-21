_:
{
  services.nginx = {
    virtualHosts."piss-your.se" = {
      listenAddresses = [ "0.0.0.0" "[::0]" ];
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      root = ./piss-your.se;

      locations."= /" = {
        return = "301 /f";
      };
    };
  };
}
