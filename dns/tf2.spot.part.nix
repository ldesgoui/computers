{ config, inputs, ... }:
let
  inherit (inputs) dns;

  wi = config.dns.zones."lde.sg".subdomains.wi.subdomains;
in
{
  dns.zones."tf2.spot" = {
    SOA = {
      nameServer = "ns1.piss-your.se.";
      adminEmail = "admin@tf2.spot";
      serial = 1;
    };

    NS = [
      "ns1.piss-your.se."
      # "ns2.piss-your.se."
    ];

    CAA = dns.lib.letsEncrypt "ldesgoui@gmail.com";

    inherit (wi.soldier) A AAAA;

    MX = [{ exchange = "mx1.lde.sg."; preference = 10; }];

    TXT = [ (dns.lib.spf.strict [ "mx ra=postmaster" ]) ];

    DKIM = [
      {
        selector = "202509e";
        k = "ed25519";
        h = "sha256";
        p = "ooPxqxxfCvM+oCQF/o+OGlJYOY6Ui2tnuP2Bwb2ud/I=";
      }
      {
        selector = "202509r";
        k = "rsa";
        h = "sha256";
        p = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwklM5belYHXH1m5WGhdoCbl+NGWBfS9Vi4ihh2xcxC86x+znmGwfSZYF3eFDyMqfo4tSI8SBgD6RMtRkGqM9zLtszDOMhnQzk12wpR6Vi/2LcqnN0TX0K/WYV03Wnb+SYZL6xPKgzIOZgqO3sdacEx6Uo6C5n0yKng2u3QUhZV5Ot2DE2G1knV9uF7jFqfJn3YaV6jY2zN9wWk4l+liWN4B50pp9KEOgzhwIUJIr42G5rxi/0B2Lj+TjhxII0tugUf1goyy4hv6O3eRw+VqJTS36GXgRuxkXM5dOMmg5cm9SELN1vctRpzvBJ9Vo/KajtM8TIvzmGBKQkHddEIkU2QIDAQAB";
      }
    ];

    DMARC = [{
      p = "reject";
      rua = "mailto:postmaster@tf2.spot";
      ruf = [ "mailto:postmaster@tf2.spot" ];
    }];

    subdomains = {
      autoconfig.CNAME = [ "mx1.lde.sg." ];

      _tls.subdomains._smpt.TXT = [{ data = "v=TLSRPTv1; rua=mailto:postmaster@lde.sg"; }];

      fantasy.CNAME = [ "soldier.wi.lde.sg." ];
      mathesar.CNAME = [ "soldier.wi.lde.sg." ];
    };
  };
}
