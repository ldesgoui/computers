{ inputs, ... }:
let
  inherit (inputs) dns;
  inherit (dns.lib) host;

  wi = {
    soldier = host "109.190.105.250" "2001:41d0:fc14:ca00:3e7c:3fff:fe22:bb0d";
    sniper = host "212.47.233.201" "2001:bc8:710:7dfc:dc00:ff:fe90:1119";
  };

  ts = {
    scout = host "100.101.0.18" "fd7a:115c:a1e0::1a7c";
    soldier = host "100.101.0.5" "fd7a:115c:a1e0::ced8";
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

      mx1.CNAME = [ "soldier.wi" ];
      mx2.CNAME = [ "sniper.wi" ];

      autoconfig.CNAME = [ "mx1" ];

      acted-wtf-temporary-for-northernlion.CNAME = [ "soldier.wi" ];

      auth.CNAME = [ "soldier.wi" ];
      headscale.CNAME = [ "soldier.wi" ];

      cool-zone.SRV = [{
        service = "mumble";
        proto = "tcp";
        port = 64738;
        target = "soldier.wi";
      }];

      int.subdomains = {
        syncthing-soldier = ts.soldier;

        vaultwarden = ts.soldier;
        stalwart = ts.soldier;

        jellyfin = ts.soldier;
        jellyseerr = ts.soldier;
        radarr = ts.soldier;
        sonarr = ts.soldier;
        lidarr = ts.soldier;
        bazarr = ts.soldier;
        prowlarr = ts.soldier;
        jackett = ts.soldier;
        transmission = ts.soldier;
        deluge = ts.soldier;

        thelounge = ts.soldier;
        vikunja = ts.soldier;
      };
    };
  };
}
