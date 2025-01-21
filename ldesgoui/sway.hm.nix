_:
{ lib, config, pkgs, ... }:
let
  cfg = config.wayland.windowManager.sway.config;
in
{
  home.packages = [
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
  ];

  programs.bash = {
    profileExtra = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
      fi
    '';
  };

  services.swayidle = {
    enable = true;

    events = [{
      event = "before-sleep";
      command = "swaylock --daemonize";
    }];

    timeouts = [
      {
        timeout = 60;
        command = "${pkgs.sway}/bin/swaymsg 'output * power off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
      }
      {
        timeout = 30 * 60;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };

  wayland.windowManager.sway = {
    enable = true;

    config = {
      # input."*".xkb_options = "compose:ralt";

      input."type:touchpad" = {
        tap = "enabled";
        scroll_method = "two_finger";
      };

      input."1133:50509:Logitech_USB_Receiver".pointer_accel = "-0.75";

      modifier = "Mod4";
      keybindings = lib.mkOptionDefault {
        "${cfg.modifier}+p" = "exec grim -g \"$(slurp)\" - | wl-copy -t image/png";
        "${cfg.modifier}+Shift+p" = "exec grim - | wl-copy -t image/png";
      };

      terminal = "alacritty";
      menu = "bemenu-run";
    };

    wrapperFeatures.gtk = true;
  };
}
