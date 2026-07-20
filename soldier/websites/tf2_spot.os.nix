_:
{
  services.nginx = {
    virtualHosts."tf2.spot" = {
      listen = import ../nginx-listen.nix;
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      root = ./tf2.spot;
    };
  };
}
