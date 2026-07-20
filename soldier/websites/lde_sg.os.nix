_:
{
  services.nginx = {
    virtualHosts."lde.sg" = {
      listen = import ../nginx-listen.nix;
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      root = ./lde.sg;
    };

    virtualHosts."ldesgoui.xyz" = {
      listen = import ../nginx-listen.nix;
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      globalRedirect = "lde.sg";
    };
  };
}

