{ config, inputs, ... }:
let
  inherit (inputs) dns;
  inherit (dns.lib) host;

  nodes = config.dns.zones."lde.sg".subdomains.nodes.subdomains;
in
{
  dns.zones."lde.sg" = {
    TTL = 300; # TODO: remove when we're chill

    SOA = {
      nameServer = "ns1.lde.sg.";
      adminEmail = "ldesgoui@gmail.com";
      serial = 1;
    };

    NS = [
      "ns1.lde.sg." # soldier
      "ns2.lde.sg." # sniper
    ];

    CAA = dns.lib.letsEncrypt "ldesgoui@gmail.com";

    inherit (nodes.sniper) A AAAA;

    subdomains = {
      # ns1 = nodes."soldier"; # Must be glue
      # ns2 = nodes."sniper"; # Must be glue

      # auth = nodes."soldier";
      # headscale = nodes."soldier";

      nodes.subdomains = {
        # Hopefully this is what I'm intended to do
        soldier = host "109.190.105.250" "2001:41d0:fc14:ca00:aaa1:59ff:fe44:7806";
        sniper = host "212.47.233.201" "2001:bc8:710:7dfc:dc00:ff:fe74:3feb";
      };

      cool-zone.SRV = [{
        service = "mumble";
        proto = "tcp";
        port = 64738;
        target = "sniper.nodes";
      }];
    };
  };
}
