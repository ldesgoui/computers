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

    inherit (wi.soldier) A;
    AAAA = [ "2001:41d0:fc14:cafe::ff:fe07:ebe9" ];

    MX = [{ exchange = "mx1"; preference = 10; }];

    TXT = [ (dns.lib.spf.strict [ "mx ra=postmaster" ]) ];

    DKIM = [
      {
        selector = "202501e";
        k = "ed25519";
        h = [ "sha256" ];
        p = "uwHYzCCFXaBYt+uhys830xbAxxuP9K0BqAPlOOVi7s0=";
      }
      {
        selector = "202501r";
        k = "rsa";
        h = [ "sha256" ];
        p = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzOivDIByI+7SkjgWgahgiTaGFKl12IoKkGEu3qIJWFM6buv7YTj/BQ4Zo59Ow18Ns7+H4T68am5mCI/GRYG8Xt9D1WkcEjDP1ADUY4B3gMSAkH3Esl5eyJxBITbFOp8BAY/HAKDWuYSVCHeR3Zwexkm0L2yemlkOe1zbS2Qwchd/Ut1N6zULaDdCd03lO/BF6U2Eze4RYXILz54/j2EHcY3+BuYsuKi+Ht+753PS2uqjm5OTWUKIHRWTKj0AW5ATDAhDP6uEScmVBtUKwrWs3p0LRUZvk3+FiUh3uNwKKmiONh6huoVVyKfGM08mmy1jyVIPd2C7onYOeIjXIUD2JwIDAQAB";
      }
    ];

    DMARC = [{
      p = "reject";
      rua = "mailto:postmaster@lde.sg";
      ruf = [ "mailto:postmaster@lde.sg" ];
    }];

    subdomains = {
      wi.subdomains = wi;

      _tls.subdomains._smpt.TXT = [{ data = "v=TLSRPTv1; rua=mailto:postmaster@lde.sg"; }];

      mx1 = wi.soldier
        // { TXT = [ (dns.lib.spf.strict [ "a ra=postmaster" ]) ]; };

      autoconfig.CNAME = [ "mx1" ];

      auth.CNAME = [ "soldier.wi" ];
      headscale.CNAME = [ "soldier.wi" ];

      cool-zone.SRV = [{
        service = "mumble";
        proto = "tcp";
        port = 64738;
        target = "soldier.wi";
      }];

      passwords = {
        inherit (wi.soldier) A;
        AAAA = [ "2001:41d0:fc14:ca00::ff:feca:5885" ];
      };

      int.subdomains = {
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
      };
    };
  };
}
