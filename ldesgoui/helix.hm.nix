_:
{
  home.sessionVariables = {
    EDITOR = "hx";
  };

  programs.bash = {
    shellAliases = {
      vi = "hx";
      vim = "hx";
      nvi = "hx";
      nvim = "hx";
    };
  };

  programs.helix = {
    enable = true;

    settings = {
      theme = "sonokai-no-bg";

      editor = {
        auto-pairs = false;
        bufferline = "multiple";

        file-picker = {
          git-ignore = false;
          hidden = false;
          ignore = false;
          max-depth = 3;
        };

        lsp.display-messages = true;
      };
    };

    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "nixpkgs-fmt";
      }

      {
        name = "toml";
        auto-format = true;
      }

      {
        name = "python";
        auto-format = true;
        formatter = {
          command = "ruff";
          args = [ "format" "-" ];
        };
      }
    ];

    themes.sonokai-no-bg = {
      inherits = "sonokai";
      "ui.background" = { };
    };
  };
}
