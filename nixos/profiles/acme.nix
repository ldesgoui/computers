{ pkgs, ... }: {
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ldesgoui@gmail.com";

      dnsProvider = "rfc2136";
      environmentFile = pkgs.writeText "rfc2136-nameserver.txt" ''
        RFC2136_NAMESERVER=127.0.0.1
      '';

      dnsResolver = "1.1.1.1:53";
    };
  };
}
