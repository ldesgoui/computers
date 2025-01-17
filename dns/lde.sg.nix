{ inputs, ... }:
let
  inherit (inputs) dns;
  inherit (dns.lib) host;

  wi = {
    soldier = host "109.190.105.250" "2001:41d0:fc14:ca00:aaa1:59ff:fe44:7806";
    sniper = host "212.47.233.201" "2001:bc8:710:7dfc:dc00:ff:fe74:3feb";
  };
in
{
  dns.zones."lde.sg" = {
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

    MX = [{ exchange = "mx1"; preference = 10; }];

    TXT = [ (dns.lib.spf.strict [ "mx a ra=postmaster" ]) ];

    DMARC = [{
      p = "reject";
      rua = "mailto:postmaster@lde.sg";
      ruf = [ "mailto:postmaster@lde.sg" ];
    }];

    subdomains = {
      wi.subdomains = wi;

      mx1 = wi.soldier;
      mx2 = wi.sniper;

      autoconfig.CNAME = [ "mx1" ];

      auth = wi.soldier;
      headscale = wi.soldier;

      cool-zone.SRV = [{
        service = "mumble";
        proto = "tcp";
        port = 64738;
        target = "soldier.wi";
      }];
    };
  };
}
