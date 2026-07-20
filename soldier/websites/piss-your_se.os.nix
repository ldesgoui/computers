_:
{
  services.nginx = {
    virtualHosts."piss-your.se" = {
      listen = import ../nginx-listen.nix;
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
