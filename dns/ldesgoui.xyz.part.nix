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

    TXT = [ (dns.lib.spf.strict [ "mx ra=postmaster" ]) ];

    DKIM = [
      {
        selector = "202501e";
        k = "ed25519";
        h = "sha256";
        p = "7mrTqLxCj5dtUJZ9xhrkE4UE5RDayp9+LYbQz/KiAVY=";
      }
      {
        selector = "202501r";
        k = "rsa";
        h = "sha256";
        p = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsi8vECxGl1U4LnCADQzoDZ5vzPC4MvmpHLOCVIiuXlnsIw0w/lr08AOf9su5axwrnm7TxWSFvQLYdDYFeVBrfMncvfwQp3fSGu1wNSpX9NGBitP12IHg4bYz+BydoRJJ9EDvdm1XvrKXj3ZFWddF1OccTNyTfsn0N18gNdbE3BaqOb1fQUT9syiQLA5LqH6OFeqQa+k439VtmN1JEnHqEyffydLc3t9yX+BS1WuCRwYxUdjIFsl7JLuyIY6Pmt0wj7tK0gBShaDhD72LRwcB0IkxztMb/na7JnhTy7gFJmbFOdi0sjNzjltJ7iDXKrDBrJSPguBu7iRVkLvrNbRCRwIDAQAB";
      }
    ];

    DMARC = [{
      p = "reject";
      rua = "mailto:postmaster@ldesgoui.xyz";
      ruf = [ "mailto:postmaster@ldesgoui.xyz" ];
    }];

    subdomains = {
      autoconfig.CNAME = [ "mx1.lde.sg." ];

      _tls.subdomains._smpt.TXT = [{ data = "v=TLSRPTv1; rua=mailto:postmaster@lde.sg"; }];

      jf.CNAME = [ "soldier.wi.lde.sg." ];
      js.CNAME = [ "soldier.wi.lde.sg." ];

      mumble.CNAME = [ "soldier.wi.lde.sg." ];
    };
  };
}
