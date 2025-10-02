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
        max=0
        for id in phy{0..7}; do
          path="/dev/disk/by-path/pci-0000:06:00.0-sas-''${id}-lun-0"
          if [[ -f "$path" ]]; then
            rm -f $RUNTIME_DIRECTORY/$id
          else
            temp=$(( 1000 * $(${lib.getExe pkgs.hddtemp} -n "$path") ))
            echo "$temp" > $RUNTIME_DIRECTORY/$id
            if [ $temp -gt $max ]; then
              max=$temp
            fi
          fi
        done
        echo "$max" > "$RUNTIME_DIRECTORY/max"
      done
    '';

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      RuntimeDirectory = "coolercontrol-sas-temperature";
      User = "root"; # TODO: don't use root
    };
  };
}
