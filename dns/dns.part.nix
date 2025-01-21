{ lib, config, inputs, ... }:
let
  inherit (inputs) dns;
in
{
  options.dns = {
    zones = lib.mkOption {
      type = lib.types.attrsOf dns.lib.types.zone;
    };
  };

  config = {
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
