_:
{
  systemd.network = {
    networks."10-vlan100" = {
      matchConfig.MACAddress = "3c:7c:3f:22:bb:0d";
      networkConfig = {
        DHCP = true;
        IPv6PrivacyExtensions = "kernel";
        VLAN = "vlan100";
      };
    };

    netdevs."20-vlan100" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan100";
      };
      vlanConfig.Id = 100;
    };
  };
}
