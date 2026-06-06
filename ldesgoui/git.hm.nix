{ inputs, ... }:
{ pkgs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) config system; };
in
{
  programs.git = {
    enable = true;

    settings = {
      user.name = "ldesgoui";
      user.email = "ldesgoui@gmail.com";

      alias = {
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
  };

  programs.jujutsu = {
    enable = true;
    package = pkgs-unstable.jujutsu;
    settings = {
      user.name = "ldesgoui";
      user.email = "ldesgoui@gmail.com";

      ui.default-command = "status";
      ui.paginate = "never";
    };
  };
}
