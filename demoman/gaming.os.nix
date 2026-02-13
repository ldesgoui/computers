_:
{ lib, pkgs, ... }: {
  home-manager.users.ldesgoui = {
    home.packages = (builtins.attrValues {
      inherit (pkgs)
        mumble
        ;
    });
  };

  programs.steam = {
    enable = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
    "claude-code"
  ];
}
