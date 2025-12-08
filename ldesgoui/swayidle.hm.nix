_:
{ pkgs, ... }: {
  services.swayidle = {
    enable = true;

    events = [{
      event = "before-sleep";
      command = "${pkgs.niri}/bin/niri msg action lockScreen enable";
    }];

    timeouts = [
      {
        timeout = 60;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
        resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
      }
      {
        timeout = 30 * 60;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
}
