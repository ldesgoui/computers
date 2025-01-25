_:
{
  services.nginx.virtualHosts."dumbass.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:55080";
  };
}
