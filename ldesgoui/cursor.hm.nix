_:
{ pkgs, ... }:
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";

    gtk.enable = true;
    sway.enable = true;
  };
}

