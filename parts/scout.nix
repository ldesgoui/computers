{ config, lib, inputs, ... }: {
  flake.nixosConfigurations = {
    scout = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = builtins.attrValues {
        inherit (config.flake.nixosModules)
          flake-inputs
          zfs

          profiles-scout
          profiles-scout-hardware
          profiles-scout-storage

          profiles-defaults
          profiles-graphical
          profiles-nix
          profiles-sound
          profiles-user-ldesgoui
          profiles-zfs-datasets
          ;

        inherit (inputs.home-manager.nixosModules) home-manager;
        inherit (inputs.nixos-hardware.nixosModules) framework;
      };
    };
  };

  flake.nixosModules = {
    profiles-scout = { pkgs, ... }: {
      networking.hostName = "scout";

      system.stateVersion = "22.11";

      # NixOS config
      hardware.opengl = {
        enable = true;
      };

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      networking.networkmanager.enable = true;
      users.users.ldesgoui.extraGroups = [ "networkmanager" ];

      programs.dconf.enable = true;

      # Home-manager config
      home-manager.users.ldesgoui = { config, ... }: {
        programs.firefox = {
          enable = true;
        };

        home.stateVersion = "22.11";

        home.packages = (builtins.attrValues {
          inherit (pkgs)
            fd file httpie moreutils ripgrep
            grim pavucontrol slurp wl-clipboard
            fira paratype-pt-serif work-sans
            ;

          fira-mono = pkgs.nerdfonts.override { fonts = [ "FiraMono" ]; };
        }) ++ [
          # Nix
          pkgs.nil
          pkgs.nixpkgs-fmt

          # Bash
          pkgs.nodePackages.bash-language-server
          pkgs.shellcheck
        ];

        home.sessionVariables = {
          EDITOR = "hx";

          # https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
          CARGO_HOME = "${config.xdg.dataHome}/cargo";
          HTTPIE_CONFIG_DIR = "${config.xdg.configHome}/httpie";
          LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
          LESSKEY = "${config.xdg.configHome}/less/lesskey";
          SQLITE_HISTORY = "${config.xdg.cacheHome}/sqlite_history";
        };

        programs.alacritty = {
          enable = true;
          settings = {
            font.normal.family = "FiraMono Nerd Font";
            selection.save_to_clipboard = true;
            window.padding = { x = 4; y = 4; };
          };
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

          profileExtra = ''
            if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
              exec sway
            fi
          '';

          initExtra = ''
            export PROMPT_COMMAND='history -a'
            export PS1='\n\w \$ '
          '';
        };

        programs.exa = {
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
              config.nil.formatting.command = [ "nixpkgs-fmt" ];
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

        services.fnott = {
          enable = true;
          settings.main = {
            title-font = "FiraMono Nerd Font:size=7";
            summary-font = "Work Sans:size=18:weight=Light";
            body-font = "PT Serif:size=9";
          };
        };

        wayland.windowManager.sway = {
          config = rec {
            modifier = "Mod4";
            keybindings = lib.mkOptionDefault {
              "${modifier}+p" = "exec grim -g \"$(slurp)\" - | wl-copy -t image/png";
              "${modifier}+Shift+p" = "exec grim - | wl-copy -t image/png";
            };
            terminal = "alacritty";
          };

          wrapperFeatures.gtk = true;
        };

        xdg = {
          enable = true;
        };
      };
    };

    profiles-scout-hardware = {
      boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" ];
      boot.kernelModules = [ "kvm-intel" ];

      hardware.enableRedistributableFirmware = true;

      powerManagement.cpuFreqGovernor = "powersave";

      services.fwupd = {
        enable = true;
      };
    };

    profiles-scout-storage = {
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      boot.initrd = {
        availableKernelModules = [ "nvme" ];
      };

      boot.zfs = {
        enableRecommended = true;
      };

      boot.zfs.pools.main = {
        vdevs = [ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNS0T108224Y-part2" ];

        properties = {
          ashift = "12";
          autotrim = "on";
          compatibility = "openzfs-2.1-linux";
        };
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNS0T108224Y-part1";
        fsType = "vfat";
      };

      networking.hostId = "11111111"; # For ZFS

      swapDevices = [{
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNS0T108224Y-part3";
      }];
    };
  };
}
