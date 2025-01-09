{ config, inputs, ... }:
let
  inherit (inputs) dns;
  nodes = config.dns.zones."lde.sg".subdomains.nodes.subdomains;
in
{
  dns.zones."piss-your.se" = {
    TTL = 300; # TODO: remove when we're chill

    SOA = {
      nameServer = "ns1.lde.sg.";
      adminEmail = "ldesgoui@gmail.com";
      serial = 1;
    };

    NS = [
      "ns1.lde.sg."
      "ns2.lde.sg."
    ];

    CAA = dns.lib.letsEncrypt "ldesgoui@gmail.com";

    inherit (nodes.soldier) A AAAA;
  };
}
