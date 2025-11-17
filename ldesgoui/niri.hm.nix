_:
{
  programs.bash = {
    profileExtra = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty2" ]; then
        exec niri --session
      fi
    '';
  };
}
