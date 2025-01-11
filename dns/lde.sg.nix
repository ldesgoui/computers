{ inputs, ... }:
let
  inherit (inputs) dns;
  inherit (dns.lib) host;

  nodes = {
    soldier = host "109.190.105.250" "2001:41d0:fc14:ca00:aaa1:59ff:fe44:7806";
    sniper = host "212.47.233.201" "2001:bc8:710:7dfc:dc00:ff:fe74:3feb";
  };
in
{
  dns.zones."lde.sg" = {
    TTL = 300; # TODO: remove when we're chill

    SOA = {
      nameServer = "ns1.piss-your.se.";
      adminEmail = "ldesgoui@gmail.com";
      serial = 1;
    };

    NS = [
      "ns1.piss-your.se."
      # "ns2.piss-your.se."
    ];

    CAA = dns.lib.letsEncrypt "ldesgoui@gmail.com";

    inherit (nodes.soldier) A AAAA;

    subdomains = {
      auth = nodes.soldier;
      headscale = nodes.soldier;

      nodes.subdomains = nodes;

      cool-zone.SRV = [{
        service = "mumble";
        proto = "tcp";
        port = 64738;
        target = "soldier.nodes";
      }];
    };
  };
}
