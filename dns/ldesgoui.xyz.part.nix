{ config, inputs, ... }:
let
  inherit (inputs) dns;

  wi = config.dns.zones."lde.sg".subdomains.wi.subdomains;
in
{
  dns.zones."ldesgoui.xyz" = {
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

    subdomains = {
      jf.CNAME = [{ cname = "soldier.wi.lde.sg."; ttl = 600; }];
      js.CNAME = [{ cname = "soldier.wi.lde.sg."; ttl = 600; }];

      mumble.CNAME = [{ cname = "sniper.wi.lde.sg."; ttl = 600; }];
    };
  };
}
