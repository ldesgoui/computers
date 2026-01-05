{ config, inputs, ... }:
let
  inherit (inputs) dns;

  wi = config.dns.zones."lde.sg".subdomains.wi.subdomains;
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
      # "ns2.piss-your.se."
    ];

    CAA = dns.lib.letsEncrypt "ldesgoui@gmail.com";

    inherit (wi.soldier) A AAAA;

    MX = [{ exchange = "mx1.lde.sg."; preference = 10; }];

    TXT = [ (dns.lib.spf.strict [ "mx a ra=postmaster" ]) ];

    DMARC = [{
      p = "reject";
      rua = "mailto:postmaster@tf2.spot";
      ruf = [ "mailto:postmaster@tf2.spot" ];
    }];

    subdomains = {
      autoconfig.CNAME = [ "mx1.lde.sg." ];

      fantasy.CNAME = [ "soldier.wi.lde.sg." ];
    };
  };
}
