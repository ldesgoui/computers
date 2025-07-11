_:
{ pkgs, ... }:
{
  fonts.enableDefaultPackages = true;

  fonts.packages = [
    pkgs.fira
    pkgs.paratype-pt-serif
    pkgs.work-sans
    pkgs.nerd-fonts.fira-mono
  ];
}
