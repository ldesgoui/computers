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
        syncthing-scout.CNAME = [ "scout.ts" ];
        syncthing-soldier.CNAME = [ "soldier.ts" ];

        vaultwarden.CNAME = [ "soldier.ts" ];
        stalwart.CNAME = [ "soldier.ts" ];

        jellyfin.CNAME = [ "soldier.ts" ];
        jellyseerr.CNAME = [ "soldier.ts" ];
        radarr.CNAME = [ "soldier.ts" ];
        sonarr.CNAME = [ "soldier.ts" ];
        lidarr.CNAME = [ "soldier.ts" ];
        bazarr.CNAME = [ "soldier.ts" ];
        prowlarr.CNAME = [ "soldier.ts" ];
        transmission.CNAME = [ "soldier.ts" ];

        thelounge.CNAME = [ "soldier.ts" ];
        mealie.CNAME = [ "soldier.ts" ];
        vikunja.CNAME = [ "soldier.ts" ];
      };
    };
  };
}
