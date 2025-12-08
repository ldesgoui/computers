_:
{
  programs.bash = {
    profileExtra = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        niri-session
      fi
    '';
  };
}
