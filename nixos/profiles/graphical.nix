{ pkgs, ... }: {
  security.polkit.enable = true;

  home-manager.users.ldesgoui = {
    fonts.fontconfig = {
      enable = true;
    };

    gtk = {
      enable = true;

      font = {
        name = "Fira Sans";
        size = 11;
      };

      iconTheme = {
        package = pkgs.tela-icon-theme;
        name = "Tela";
      };

      theme = {
        package = pkgs.stilo-themes;
        name = "Stilo-dark";
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      config.modifier = "Mod4";
    };
  };
}
