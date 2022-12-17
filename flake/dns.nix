{ self, ... }:

let
  inherit (self.inputs) dns;
  inherit (dns.lib.combinators) host letsEncrypt;
in
{
  my.dns.zones."lde.sg" = {
    TTL = 300;

    SOA = {
      nameServer = "ns1.gandi.net";
      adminEmail = "hostmaster@gandi.net";
      serial = 1645059025;
    };

    CAA = letsEncrypt "ldesgoui@gmail.com";
  };
}
