_:
{
  services.nginx = {
    virtualHosts."lde.sg" = {
      listen = [
        { addr = "0.0.0.0"; }
        { addr = "[::0]"; }
        { addr = "[fd4c:a29e:23d9::1]"; port = 9080; ssl = false; proxyProtocol = true; }
        { addr = "[fd4c:a29e:23d9::1]"; port = 9443; ssl = true; proxyProtocol = true; }
      ];
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      root = ./lde.sg;
    };

    virtualHosts."ldesgoui.xyz" = {
      listen = [
        { addr = "0.0.0.0"; }
        { addr = "[::0]"; }
        { addr = "[fd4c:a29e:23d9::1]"; port = 9080; ssl = false; proxyProtocol = true; }
        { addr = "[fd4c:a29e:23d9::1]"; port = 9443; ssl = true; proxyProtocol = true; }
      ];
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      globalRedirect = "lde.sg";
    };
  };
}

