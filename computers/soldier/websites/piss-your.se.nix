{ pkgs, ... }: {
  security.acme.certs."piss-your.se" = {
    dnsProvider = "rfc2136";
    environmentFile = pkgs.writeText "rfc2136-nameserver.txt" ''
      RFC2136_NAMESERVER=127.0.0.1
    '';
  };

  services.nginx = {
    virtualHosts."piss-your.se" = {
      listenAddresses = [ "0.0.0.0" "[::0]" ];
      enableACME = true;
      acmeRoot = null;

      root = ./piss-your.se;

      locations."= /" = {
        return = "301 https://piss-your.se/f";
      };
    };
  };
}
