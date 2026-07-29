{ config, inputs, ... }:
let
  inherit (inputs) dns;
  wi = config.dns.zones."lde.sg".subdomains.wi.subdomains;
in
{
  dns.zones."piss-your.se" = {
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

    MX = [{ exchange = "mx1.lde.sg."; preference = 10; }];

    TXT = [ (dns.lib.spf.strict [ "mx ra=postmaster" ]) ];

    DKIM = [
      {
        selector = "202501e";
        k = "ed25519";
        h = [ "sha256" ];
        p = "mAujEmbxvPSofnocQMfcjz10kIHyRFB3nOde8B0SePY=";
      }
      {
        selector = "202501r";
        k = "rsa";
        h = [ "sha256" ];
        p = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwoBnSBD3TrRzddkxPyTXEEGsi3X4LdBJSbpJ7kfmiaDQNiet7p9d6vmaZYasRXZcT/wGLqld7+pIaztXMM8Sn/UHuhN+TDxYAax71eAmqIXj+HGqsx87RM1NUVSNsABQI/xFD3aqwe/Q69XCGnGfW7/fKaqwXTRU0qAoDi2/AxRWDs/eFfDfj/Mw+c7De+ojhMuX5rc8IQCU9J/GF2/zCKEbfPWLUT7NYnfH2vZ/Prisp1VcS61GCq6ygveP4SKEKIv6Kn1v8NV1VO0vBqBQLbgNiO/eE+H52xVnyc5/14S0lnZY2POlcnFqVFg6HIaCjoU2c+JeBO3p3b/vzyRUSQIDAQAB";
      }
    ];

    DMARC = [{
      p = "reject";
      rua = "mailto:postmaster@piss-your.se";
      ruf = [ "mailto:postmaster@piss-your.se" ];
    }];

    subdomains = {
      ns1 = {
        inherit (wi.soldier) A; # Must be glue
      };
      ns2 = wi.sniper; # Must be glue

      autoconfig.CNAME = [ "mx1.lde.sg." ];

      _tls.subdomains._smpt.TXT = [{ data = "v=TLSRPTv1; rua=mailto:postmaster@lde.sg"; }];
    };
  };
}
