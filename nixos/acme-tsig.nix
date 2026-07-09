{ self, ... }: {
  flake.nixosModules.acme-tsig = { config, pkgs, ... }:
    let
      inherit (config.networking) hostName;

      nameserver = "[2001:41d0:fc14:cafe::ff:fe00:53]";
      physNames = [ "scout" "soldier" "pyro" "demoman" "heavy" "engineer" "medic" "sniper" "spy" ];
      dir = if builtins.elem hostName physNames then "phys" else "virt";
    in
    {
      age.secrets.acme-tsig = {
        rekeyFile = "${self}/${dir}/${hostName}/acme-tsig.age";
        generator.script = "knot-tsig";
        settings.id = "${hostName}.acme";
      };

      age.secrets.acme-tsig-env = {
        rekeyFile = "${self}/${dir}/${hostName}/acme-tsig-env.age";
        generator = {
          dependencies = { inherit (config.age.secrets) acme-tsig; };
          script = { decrypt, deps, lib, pkgs, ... }: ''
            ${decrypt} ${lib.escapeShellArg deps.acme-tsig.file} \
            | ${pkgs.yq-go}/bin/yq eval -o=shell '
              .key[0] | {
                "RFC2136_TSIG_KEY": .id,
                "RFC2136_TSIG_ALGORITHM": .algorithm,
                "RFC2136_TSIG_SECRET": .secret
              }
            '
          '';
        };
      };

      security.acme = {
        acceptTerms = true;
        defaults = {
          email = "ldesgoui@gmail.com";

          dnsProvider = "rfc2136";
          environmentFile = config.age.secrets.acme-tsig-env.path;
          credentialFiles = {
            RFC2136_NAMESERVER_FILE = builtins.toFile "nameserver.txt" nameserver;
          };

          dnsResolver = "1.1.1.1:53";
        };
      };
    };
}
