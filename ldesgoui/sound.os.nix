_:
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.helvum
    pkgs.pavucontrol
  ];

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
