_:
{ lib, ... }: {
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 5;

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };
}
