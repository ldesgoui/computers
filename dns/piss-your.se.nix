{ config, inputs, ... }:
let
  inherit (inputs) dns;
  nodes = config.dns.zones."lde.sg".subdomains.nodes.subdomains;
in
{
  dns.zones."piss-your.se" = {
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
      ns1 = nodes.soldier; # Must be glue
      ns2 = nodes.sniper; # Must be glue
    };
  };
}
