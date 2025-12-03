_:
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.helvum
    pkgs.pwvucontrol
  ];

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
