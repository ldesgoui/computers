{
  services.nginx = {
    virtualHosts."lde.sg" = {
      listenAddresses = [ "0.0.0.0" "[::0]" ];
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      root = ./lde.sg;
    };

    virtualHosts."ldesgoui.xyz" = {
      listenAddresses = [ "0.0.0.0" "[::0]" ];
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      globalRedirect = "lde.sg";
    };
  };
}

