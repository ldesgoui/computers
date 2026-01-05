_:
{ config, ... }: {
  services.nginx.virtualHosts."syncthing-${config.networking.hostName}.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://${config.services.syncthing.guiAddress}";
    extraConfig = ''
      proxy_read_timeout 600s;
      proxy_send_timeout 600s;
    '';
  };

  services.syncthing = {
    settings = {
      options = {
        listenAddresses = [
          "tcp://:22000"
          "quic://:22000"
        ];
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };

      gui.insecureSkipHostcheck = true;

      devices.scout = {
        id = "QZ6VFBQ-4QJLS2Y-R4IDJ7T-CKLYC7O-7GSTGO2-K2WBRWL-MGYZBV6-XZ6ZQQE";
        addresses = [ "tcp://scout.ts.lde.sg" "quic://scout.ts.lde.sg" ];
      };

      devices.soldier = {
        id = "KOQVGTB-VDMTHL7-IV6EN45-2TGWPGW-NYYNMVF-YCLWRPD-CXEIM6C-6TWUKAL";
        addresses = [ "tcp://soldier.ts.lde.sg" "quic://soldier.ts.lde.sg" ];
      };

      devices.spy = {
        id = "JZZDZ4I-3M2EQFJ-VQYUSWC-JM6DZCV-USCEVXX-XY2FSUI-XNWLGAV-QKNLTQB";
        addresses = [ "tcp://spy.ts.lde.sg" "quic://spy.ts.lde.sg" ];
      };
    };
  };
}
