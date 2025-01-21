_:
{ config, ... }:
let
  inherit (config.xdg) dataHome cacheHome configHome;
in
{
  xdg = {
    enable = true;
  };

  # https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
  home.sessionVariables = {
    CARGO_HOME = "${dataHome}/cargo";
    HTTPIE_CONFIG_DIR = "${configHome}/httpie";
    LESSHISTFILE = "${cacheHome}/less/history";
    LESSKEY = "${configHome}/less/lesskey";
  };
}
