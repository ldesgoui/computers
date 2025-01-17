{ config, lib, inputs, ... }:
let
  inherit (inputs) dns;

  wi = config.dns.zones."lde.sg".subdomains.wi.subdomains;
in
{
  dns.zones."ldesgoui.xyz" = {
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

    MX = [ (dns.lib.mx.mx 10 "mx.ldesgoui.xyz") ];

    DKIM = [{
      selector = "mail";
      p = lib.removeSuffix "\n" (builtins.readFile ./dkim-ldesgoui.xyz.pub);
    }];

    TXT = [ (dns.lib.spf.strict [ "mx a" ]) ];

    DMARC = [{ p = "none"; }];

    inherit (wi.soldier) A AAAA;

    subdomains = {
      jf = wi.soldier;
      js = wi.soldier;
      mumble = wi.soldier;
    };
  };
}
