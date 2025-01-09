{ lib, config, inputs, ... }:
let
  inherit (inputs) dns;
in
{
  imports = [
    ./lde.sg.nix
    ./ldesgoui.xyz.nix
    ./piss-your.se.nix
  ];

  options.dns = {
    zones = lib.mkOption {
      type = lib.types.attrsOf dns.lib.types.zone;
    };
  };

  config = {
    flake.nixosModules.hickory-zones = { pkgs, ... }: {
      services.hickory-dns.settings.zones = lib.mapAttrsToList
        (name: zone: {
          zone = name;
          file = pkgs.writeTextFile {
            name = "${name}.zone";
            text = toString zone;
          };
        })
        config.dns.zones;
    };

    perSystem = { pkgs, system, ... }: {
      packages.dns-zones = lib.pipe config.dns.zones [
        (lib.mapAttrsToList (name: zone: pkgs.writeTextFile {
          name = "${name}.zone";
          text = toString zone;
        }))
        (pkgs.linkFarmFromDrvs "dns-zones")
      ];
    };
  };
}
