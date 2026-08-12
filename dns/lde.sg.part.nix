{ inputs, ... }:
let
  inherit (inputs) dns;
  inherit (dns.lib) host;

  wi = {
    soldier = host "109.190.105.250" "2001:41d0:fc14:ca00:3e7c:3fff:fe22:bb0d";
    sniper = host "212.47.233.201" "2001:bc8:710:7dfc::8";
  };

  ts = {
    scout = host "100.101.0.18" "fd7a:115c:a1e0::1a7c";
    soldier = host "100.101.0.5" "fd7a:115c:a1e0::ced8";
  };
in
{
  dns.zones."lde.sg" = {
    TTL = 600;

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
      wi.subdomains = wi;

      auth = {
        A = [
          "212.47.233.201"
          # "109.190.105.250"
        ];
        AAAA = [
          "2001:bc8:710:7dfc::8"
          # "2001:41d0:fc14:cafe::ff:feac:f436"
        ];
      };

      auth-repl.subdomains = {
        sniper.AAAA = [ "2001:bc8:710:7dfc::8" ];
        vm.AAAA = [ "2001:41d0:fc14:cafe::ff:feac:f436" ];
      };

      headscale.CNAME = [ "soldier.wi" ];

      cool-zone.CNAME = [ "sniper.wi" ];
      # cool-zone.SRV = [{
      #   service = "mumble";
      #   proto = "tcp";
      #   port = 64738;
      #   target = "sniper.wi";
      # }];

      passwords = {
        inherit (wi.sniper) A AAAA;
      };

      int.subdomains = {
        stalwart = ts.soldier;

        radarr = ts.soldier;
        sonarr = ts.soldier;
        lidarr = ts.soldier;
        bazarr = ts.soldier;
        prowlarr = ts.soldier;
        jackett = ts.soldier;
        transmission = ts.soldier;
        deluge = ts.soldier;

        thelounge = ts.soldier;
      };
    };
  };
}
