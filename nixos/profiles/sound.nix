{ pkgs, ... }: {
  environment.systemPackages = [
    # TODO: Don't install these if we're not going to run a GUI
    pkgs.pavucontrol

    # pkgs.helvum # TODO: broken
  ];

  security.rtkit.enable = true; # XXX: IDK why this is useful, nixos.wiki suggests it

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
