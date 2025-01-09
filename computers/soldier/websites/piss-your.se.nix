{
  services.nginx = {
    virtualHosts."piss-your.se" = {
      listenAddresses = [ "0.0.0.0" "[::0]" ];
      enableACME = true;
      acmeRoot = null;

      root = ./piss-your.se;

      locations."= /" = {
        return = "301 https://piss-your.se/f";
      };
    };
  };
}
