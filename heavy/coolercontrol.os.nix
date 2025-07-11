_:
{ lib, pkgs, ... }: {
  boot.kernelModules = [
    "drivetemp"
    "nct6775"
  ];

  programs.coolercontrol = {
    enable = true;
  };

  services.nginx.virtualHosts."coolercontrol-heavy.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:11987";
  };

  systemd.services.coolercontrol-liqctld.enable = false;

  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "lsiutil";

  systemd.services."coolercontrol-lsi-temperature" = {
    script = ''
      set -eu
      while sleep 1; do
        ${pkgs.lsiutil}/bin/lsiutil -p1 -a 25,2,0,0 \
          | ${lib.getExe pkgs.gawk} '/IOCTemperature: /{print strtonum($2)*1000}' \
          > $RUNTIME_DIRECTORY/temp
      done
    '';

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      RuntimeDirectory = "coolercontrol-lsi-temperature";
      User = "root"; # TODO: don't use root
    };
  };

  systemd.services."coolercontrol-sas-temperature" = {
    script = ''
      set -eu
      while sleep 1; do
        for id in wwn-0x5000c500f4784a67 wwn-0x6000c500d81c4aef0000000000000000 wwn-0x6000c500d8147dd30000000000000000 wwn-0x6000c500d81432230000000000000000; do
          echo $(( 1000 * $(${lib.getExe pkgs.hddtemp} -n /dev/disk/by-id/$id) )) > $RUNTIME_DIRECTORY/$id
        done
      done
    '';

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      RuntimeDirectory = "coolercontrol-sas-temperature";
      User = "root"; # TODO: don't use root
    };
  };
}
