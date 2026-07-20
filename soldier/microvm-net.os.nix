_:
{
  systemd.network = {
    netdevs."10-br-mgmt" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br-mgmt";
      };
    };

    netdevs."10-vlan100" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan100";
      };
      vlanConfig.Id = 100;
    };

    networks."20-br-mgmt" = {
      matchConfig.Name = "br-mgmt";
      addresses = [{
        Address = [ "fd4c:a29e:23d9::1/64" ];
      }];
      networkConfig = {
        IPv6SendRA = true;
      };
      ipv6Prefixes = [{
        Prefix = [ "fd4c:a29e:23d9::/64" ];
      }];
    };

    networks."20-vlan100" = {
      matchConfig.MACAddress = "3c:7c:3f:22:bb:0d";
      networkConfig = {
        DHCP = true;
        IPv6PrivacyExtensions = "kernel";
        VLAN = "vlan100";
      };
    };
  };
}
