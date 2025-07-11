_:
{ lib, pkgs, ... }: {
  boot.kernelModules = [
    "drivetemp"
    "nct6775"
  ];

  programs.coolercontrol = {
    enable = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "lsiutil";

  systemd.services."coolercontrol-lsi-temperature" = {
    script = ''
      set -eu
      ${pkgs.lsiutil}/bin/lsiutil -p1 -a 25,2,0,0 \
        | ${lib.getExe pkgs.gawk} '/IOCTemperature: /{print strtonum($2)*1000}' \
        > $RUNTIME_DIRECTORY/temp
    '';

    serviceConfig = {
      RuntimeDirectory = "coolercontrol-lsi-temperature";
      Type = "oneshot";
      User = "root";
    };

    unitConfig = {
      StartLimitIntervalSec = 0;
    };
  };

  systemd.timers."coolercontrol-lsi-temperature" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      AccuracySec = "100ms";
      OnBootSec = "1min";
      OnUnitActiveSec = "1s";
      Unit = "coolercontrol-lsi-temperature.service";
    };
  };
}
