_:
{ pkgs, ... }: {
  programs.dconf.enable = true;

  home-manager.users.ldesgoui = {
    gtk =
      let
        theme = {
          package = pkgs.stilo-themes;
          name = "Stilo-dark";
        };
      in
      {
        enable = true;

        font = {
          name = "Fira Sans";
          size = 11;
        };

        iconTheme = {
          package = pkgs.tela-icon-theme;
          name = "Tela";
        };

        theme = theme;
        gtk4.theme = theme;
      };
  };
}
