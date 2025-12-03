_:
{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  programs.niri.enable = true;
}
