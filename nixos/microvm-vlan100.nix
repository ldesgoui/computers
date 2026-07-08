{
  flake.nixosModules.microvm-vlan100 =
    { config, lib, ... }:
    let
      inherit (config.microvm) machineId;

      l = n: builtins.substring (n * 2) 2 machineId;

      macAddress = "02:00:00:${l 0}:${l 1}:${l 2}";
    in
    {
      microvm = {
        interfaces = [{
          type = "macvtap";
          id = "vm-${builtins.substring 0 12 config.networking.hostName}";
          mac = macAddress;
          macvtap.link = "vlan100";
          macvtap.mode = "bridge";
        }];
      };
    };
}
