{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge;

  cfg = config.ldesgoui;
in
{
  options.ldesgoui = {
    enable = mkEnableOption "user 'ldesgoui'";

    graphical = mkEnableOption "graphical session";

    dev.nix = mkEnableOption "nix dev tools";
    dev.bash = mkEnableOption "nix dev tools";
  };

  config = mkIf (cfg.enable) (mkMerge [
    {
      boot.zfs.datasets = {
        main._.enc._.users._.ldesgoui = {
          # We would prefer using `config.users.users.ldesgoui.home` here
          # but doing so causes an infinite recursion error.
          mountPoint = "/home/ldesgoui";
        };
      };

      nix.settings.trusted-users = [ "ldesgoui" ];

      users.users.ldesgoui = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };

      home-manager.users.ldesgoui = { config, ... }: {
        home.packages = lib.mkMerge [
          (builtins.attrValues {
            inherit (pkgs)
              fd file httpie moreutils ripgrep
              ;
          })

          (lib.mkIf cfg.dev.nix [
            pkgs.nil
            pkgs.nixpkgs-fmt
          ])

          (lib.mkIf cfg.dev.bash [
            pkgs.nodePackages.bash-language-server
            pkgs.shellcheck
          ])
        ];

        home.sessionVariables = {
          EDITOR = "hx";

          # https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
          CARGO_HOME = "${config.xdg.dataHome}/cargo";
          HTTPIE_CONFIG_DIR = "${config.xdg.configHome}/httpie";
          LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
          LESSKEY = "${config.xdg.configHome}/less/lesskey";
        };

        manual = {
          html.enable = false;
          manpages.enable = false;
          json.enable = false;
        };

        programs.bash = {
          enable = true;
          enableCompletion = true;

          shellAliases = {
            vi = "hx";
            vim = "hx";
            nvi = "hx";
            nvim = "hx";
          };

          historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
          historyFile = "${config.xdg.cacheHome}/bash/history";

          initExtra = ''
            export PROMPT_COMMAND='history -a'
            export PS1='\n\w \$ '
          '';
        };

        programs.eza = {
          enable = true;
          enableAliases = true;
          git = true;
          icons = true;
          extraOptions = [ "--group-directories-first" ];
        };

        programs.fzf = {
          enable = true;
        };

        programs.git = {
          enable = true;

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
          ];

          themes.sonokai-no-bg = {
            inherits = "sonokai";
            "ui.background" = { };
          };
        };

        programs.htop = {
          enable = true;
          settings = {
            delay = 2;
            fields = with config.lib.htop.fields; [ PID USER PERCENT_CPU PERCENT_MEM TIME COMM ];
            hide_kernel_threads = true;
            hide_userland_threads = true;
            highlight_base_name = true;
            shadow_other_users = true;
            show_cpu_frequency = true;
            show_program_path = false;
            tree_view = true;
          };
        };

        programs.jq = {
          enable = true;
        };

        programs.zoxide = {
          enable = true;
        };

        xdg = {
          enable = true;
        };
      };

    }
    (lib.mkIf cfg.graphical {
      environment.systemPackages = [
        # TODO: Don't install these if we're not going to run a GUI
        pkgs.pavucontrol

        # pkgs.helvum # TODO: broken
      ];

      programs.dconf.enable = true; # Needed for home-manager.users.<name>.gtk

      security.polkit.enable = true;

      security.rtkit.enable = true; # XXX: IDK why this is useful, nixos.wiki suggests it

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      home-manager.users.ldesgoui = {
        fonts.fontconfig.enable = true;

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

        home.packages = (builtins.attrValues {
          inherit (pkgs)
            grim pavucontrol slurp wl-clipboard
            fira paratype-pt-serif work-sans

            noto-fonts-emoji
            ;

          fira-mono = pkgs.nerdfonts.override { fonts = [ "FiraMono" ]; };
        });

        programs.alacritty = {
          enable = true;
          settings = {
            font.normal.family = "FiraMono Nerd Font";
            selection.save_to_clipboard = true;
            window.padding = { x = 4; y = 4; };
          };
        };

        programs.bash = {
          profileExtra = ''
            if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
              exec sway
            fi
          '';
        };

        programs.firefox = {
          enable = true;
        };

        programs.mpv = {
          enable = true;
        };

        services.fnott = {
          enable = true;
          settings.main = {
            title-font = "FiraMono Nerd Font:size=7";
            summary-font = "Work Sans:size=18:weight=Light";
            body-font = "PT Serif:size=9";
          };
        };

        wayland.windowManager.sway = {
          enable = true;

          config = rec {
            input."*".xkb_options = "compose:ralt";

            input."type:touchpad" = {
              tap = "enabled";
              scroll_method = "two_finger";
            };

            input."1133:50509:Logitech_USB_Receiver".pointer_accel = "-0.75";

            modifier = "Mod4";
            keybindings = lib.mkOptionDefault {
              "${modifier}+p" = "exec grim -g \"$(slurp)\" - | wl-copy -t image/png";
              "${modifier}+Shift+p" = "exec grim - | wl-copy -t image/png";
            };

            terminal = "alacritty";
            menu = "${pkgs.bemenu}/bin/bemenu-run -b -W 0.5 --hp 4 --fn 'FiraMono Nerd Font'";
          };

          wrapperFeatures.gtk = true;
        };
      };
    })
  ]);
}
