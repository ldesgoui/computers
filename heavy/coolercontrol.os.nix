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
      while sleep 1; do
        ${pkgs.lsiutil}/bin/lsiutil -p1 -a 25,2,0,0 \
          | ${lib.getExe pkgs.gawk} '/IOCTemperature: /{print strtonum($2)*1000}' \
          > $RUNTIME_DIRECTORY/temp
      done
    '';

    serviceConfig = {
      RuntimeDirectory = "coolercontrol-lsi-temperature";
      User = "root"; # TODO: don't use root
    };
  };
}
