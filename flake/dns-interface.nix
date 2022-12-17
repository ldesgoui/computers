{ self, config, lib, ... }:

let
  inherit (self.inputs) dns;
in
{
  options.my.dns = {
    zones = lib.mkOption {
      type = lib.types.attrsOf dns.lib.types.zone;
    };
  };

  config.perSystem = { pkgs, ... }: {
    packages.dns-zones = lib.pipe config.my.dns.zones [
      (lib.mapAttrsToList (name: zone: pkgs.writeTextFile {
        name = "${name}.zone";
        text = toString zone;
      }))
      (pkgs.linkFarmFromDrvs "dns-zones")
    ];
  };
}
