{ config, lib, inputs, ... }:
let
  inherit (inputs) dns;
  inherit (dns.lib) host;

  nodes = config.dns.zone."lde.sg".subdomains.nodes.subdomains;
in
{
  dns.zone."ldesgoui.xyz" = {
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

    MX = [ (dns.lib.mx.mx 10 "mx.ldesgoui.xyz") ];

    DKIM = [{
      selector = "mail";
      p = lib.removeSuffix "\n" (builtins.readFile ./dkim-ldesgoui.xyz.pub);
    }];

    TXT = [ (dns.lib.spf.strict [ "mx a" ]) ];

    DMARC = [{ p = "none"; }];

    inherit (nodes.sniper) A AAAA;

    subdomains = {
      "bw.wg0" = nodes.sniper;
      jf = nodes.soldier;
      js = nodes.soldier;
      mumble = nodes.sniper;
      mx = { inherit (nodes.sniper) A; };
      www = nodes.sniper;
    };
  };
}
