_:
{
  boot.loader.systemd-boot.configurationLimit = 10;

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  environment = {
    stub-ld.enable = false;
    ldso32 = null;
  };
}
