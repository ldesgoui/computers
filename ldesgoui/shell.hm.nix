_:
{ lib, config, pkgs, ... }: {
  home.packages = [
    pkgs.fd
    pkgs.file
    pkgs.moreutils
    pkgs.ripgrep
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;

    historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    historyFile = "${config.xdg.cacheHome}/bash/history";

    initExtra = ''
      export PROMPT_COMMAND='history -a'

      if [ -n "$SSH_TTY" ]; then
        export PS1='\n\h: \w \$ '
      else
        export PS1='\n\w \$ '
      fi
    '';
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    extraOptions = [
      "--binary"
      "--group"
      "--group-directories-first"
    ];
  };

  programs.fzf = {
    enable = true;
  };
}
