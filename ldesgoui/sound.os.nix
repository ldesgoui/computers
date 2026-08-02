_:
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.pwvucontrol
  ];

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
