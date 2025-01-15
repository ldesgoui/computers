{ config, inputs, ... }:
let
  inherit (inputs) dns;
  wi = config.dns.zones."lde.sg".subdomains.wi.subdomains;
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

    inherit (wi.soldier) A AAAA;

    MX = [{ exchange = "mx1.lde.sg."; preference = 10; }];

    TXT = [ (dns.lib.spf.strict [ "mx a ra=postmaster" ]) ];

    DMARC = [{
      p = "reject";
      rua = "mailto:postmaster@piss-your.se";
      ruf = [ "mailto:postmaster@piss-your.se" ];
    }];

    subdomains = {
      ns1 = wi.soldier; # Must be glue
      ns2 = wi.sniper; # Must be glue
    };
  };
}
