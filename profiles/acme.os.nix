_:
{ config, pkgs, ... }:
let
  nameserver =
    if config.networking.hostName == "soldier" then
      "127.0.0.1"
    else
      "soldier.ts.lde.sg";
in
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ldesgoui@gmail.com";

      dnsProvider = "rfc2136";
      environmentFile = pkgs.writeText "rfc2136-nameserver.txt" ''
        RFC2136_NAMESERVER=${nameserver}
      '';

      dnsResolver = "1.1.1.1:53";
    };
  };
}
