_:
{
  networking = {
    firewall.logRefusedConnections = false;
    useNetworkd = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  systemd.services.systemd-networkd.stopIfChanged = false;
  systemd.services.systemd-resolved.stopIfChanged = false;
}
