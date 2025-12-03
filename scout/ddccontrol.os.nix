_:
{ config, ... }: {
  services.ddccontrol = {
    enable = true;
  };

  users.users.ldesgoui.extraGroups = [ config.hardware.i2c.group ];
}
