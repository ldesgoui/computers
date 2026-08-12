{ config, inputs, ... }:
let
  inherit (inputs) dns;
  wi = config.dns.zones."lde.sg".subdomains.wi.subdomains;
in
{
  dns.zones."piss-your.se" = {
    SOA = {
      nameServer = "ns1.piss-your.se.";
      adminEmail = "ldesgoui@gmail.com";
      serial = 1;
    };

    NS = [
      "ns1.piss-your.se."
      "ns2.piss-your.se."
    ];

    CAA = dns.lib.letsEncrypt "ldesgoui@gmail.com";

    A = [
      "212.47.233.201"
      # "109.190.105.250"
    ];
    AAAA = [
      "2001:bc8:710:7dfc::8"
      # "2001:41d0:fc14:cafe::ff:fe07:ebe9"
    ];

    TXT = [
      "google-site-verification=Y7qpmPxEX2RMdW6Brq0yLOq_Eu5ZP8fZLY_fJYVFjaA"
      "v=spf1 mx -all"
    ];

    subdomains = {
      ns1 = {
        inherit (wi.soldier) A; # Must be glue
      };
      ns2 = wi.sniper; # Must be glue

      mx1 = wi.sniper // { TXT = [ "v=spf1 a -all" ]; };

      hosts.subdomains = {
        sniper = wi.sniper;
      };
    };
  };
}
