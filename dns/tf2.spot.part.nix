{ config, inputs, ... }:
let
  inherit (inputs) dns;

  wi = config.dns.zones."lde.sg".subdomains.wi.subdomains;

  to-vm = {
    inherit (wi.soldier) A;
    AAAA = [ "2001:41d0:fc14:cafe:0:ff:fea8:21c1" ];
  };
in
{
  dns.zones."tf2.spot" = {
    SOA = {
      nameServer = "ns1.piss-your.se.";
      adminEmail = "admin@tf2.spot";
      serial = 1;
    };

    NS = [
      "ns1.piss-your.se."
      "ns2.piss-your.se."
    ];

    CAA = dns.lib.letsEncrypt "ldesgoui@gmail.com";

    TXT = [
      "google-site-verification=XN3UAuS1Qf5gJP_L-HqtZK3GM5qtwhKcCQfjHmGfQtY"
      "v=spf1 mx -all"
    ];

    inherit (to-vm) A AAAA;
    subdomains = {
      fantasy = to-vm;
      # postgrest = to-vm; # TODO: make postgrest public
      mathesar = to-vm;
    };
  };
}
