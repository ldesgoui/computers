_:
{ lib, pkgs, ... }: {
  systemd.user.services.inhibridge = {
    Unit = {
      Description = "Inhibridge daemon";
      PartOf = [ "graphical-session.target" ];
    };
    Service.ExecStart = lib.getExe pkgs.inhibridge;
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
