{
  flake.nixosModules.microvm-vlan100 =
    { config, lib, ... }:
    let
      inherit (config.microvm) machineId;

      l = n: builtins.substring (n * 2) 2 machineId;
      d = n: toString (lib.fromHexString (l n));

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

      systemd.network = {
        networks."10-vlan100" = {
          matchConfig.MACAddress = macAddress;
          networkConfig = {
            DHCP = "no";
            Address = [ "10.100.${d 0}.${d 1}/16" ];
            Gateway = "10.100.0.1";
            DNS = [ "10.100.0.1" ];
            IPv6AcceptRA = true;
          };
        };
      };
    };
}
