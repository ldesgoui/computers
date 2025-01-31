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
      # "ns2.piss-your.se."
    ];

    CAA = dns.lib.letsEncrypt "ldesgoui@gmail.com";

    inherit (wi.soldier) A AAAA;

    MX = [{ exchange = "mx1.lde.sg."; preference = 10; }];

    TXT = [ (dns.lib.spf.strict [ "mx a ra=postmaster" ]) ];

    DMARC = [{
      p = "reject";
      rua = "mailto:postmaster@ldesgoui.xyz";
      ruf = [ "mailto:postmaster@ldesgoui.xyz" ];
    }];

    subdomains = {
      autoconfig.CNAME = [ "mx1.lde.sg." ];

      jf.CNAME = [ "soldier.wi.lde.sg." ];
      js.CNAME = [ "soldier.wi.lde.sg." ];

      mumble.CNAME = [ "soldier.wi.lde.sg." ];
    };
  };
}
