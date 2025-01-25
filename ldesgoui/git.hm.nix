_:
{
  programs.git = {
    enable = true;

    userName = "ldesgoui";
    userEmail = "ldesgoui@gmail.com";

    aliases = {
      a = "add";
      ap = "add --patch";
      c = "commit --verbose";
      ca = "commit --amend --verbose";
      p = "push";
      pf = "push --force-with-lease";
      root = "rev-parse --show-toplevel";
      s = "status --short --branch";
      sub = "restore --staged"; # The opposite of add
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = "ldesgoui";
      user.email = "ldesgoui@gmail.com";

      ui.paginate = "never";
    };
  };
}
