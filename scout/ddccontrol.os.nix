_:
{ config, ... }: {
  hardware.i2c.enable = true;

  services.ddccontrol = {
    enable = true;
  };

  users.users.ldesgoui.extraGroups = [ config.hardware.i2c.group ];
}
