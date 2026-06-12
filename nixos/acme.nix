{ config, pkgs, ... }:
let
  nameserver = "soldier.wi.lde.sg";
  algorithm = "hmac-sha512";
in
{
  age.secrets.acme-tsig = {
    # rekeyFile = "./acme.tsig";
    generator.script = _: ''
      ${pkgs.knot-dns}/bin/keymgr --tsig X ${algorithm} | ${pkgs.yq-go} eval '.key[0].secret'
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ldesgoui@gmail.com";

      dnsProvider = "rfc2136";
      environmentFile = pkgs.writeText "rfc2136-nameserver.txt" ''
        DNSUPDATE_NAMESERVER=${nameserver}
        DNSUPDATE_TSIG_KEY=example.com
        DNSUPDATE_TSIG_ALGORITHM=${algorithm}
        DNSUPDATE_TSIG_FILE=${config.age.secrets.acme-tsig.path}
      '';

      dnsResolver = "1.1.1.1:53";
    };
  };
}
