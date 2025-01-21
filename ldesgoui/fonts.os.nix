_:
{ pkgs, ... }:
{
  fonts.enableDefaultPackages = true;

  fonts.packages = [
    pkgs.fira
    pkgs.paratype-pt-serif
    pkgs.work-sans

    (pkgs.nerdfonts.override { fonts = [ "FiraMono" ]; })
  ];
}
