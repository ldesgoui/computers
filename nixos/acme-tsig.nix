{ self, ... }: {
  self.nixosModules.acme-tsig = { config, pkgs, ... }:
    let
      inherit (config.networking) hostName;

      nameserver = "soldier.wi.lde.sg";
      algorithm = "hmac-sha512";
      physNames = [ "scout" "soldier" "pyro" "demoman" "heavy" "engineer" "medic" "sniper" "spy" ];
      dir = if builtins.elem hostName physNames then "phys" else "virt";
    in
    {
      age.secrets.acme-tsig = {
        rekeyFile = "${self}/${dir}/${hostName}/acme.tsig";
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
            DNSUPDATE_TSIG_KEY=${hostName}
            DNSUPDATE_TSIG_ALGORITHM=${algorithm}
            DNSUPDATE_TSIG_FILE=${config.age.secrets.acme-tsig.path}
          '';

          dnsResolver = "1.1.1.1:53";
        };
      };
    };
}
