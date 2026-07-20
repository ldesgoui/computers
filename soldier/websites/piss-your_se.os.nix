_:
{
  services.nginx = {
    virtualHosts."piss-your.se" = {
      listen = [
        { addr = "0.0.0.0"; }
        { addr = "[::0]"; }
        { addr = "[fd4c:a29e:23d9::1]"; port = 9080; ssl = false; proxyProtocol = true; }
        { addr = "[fd4c:a29e:23d9::1]"; port = 9443; ssl = true; proxyProtocol = true; }
      ];
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
