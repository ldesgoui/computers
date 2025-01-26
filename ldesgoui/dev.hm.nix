_:
{ pkgs, ... }: {
  home.packages = [
    pkgs.httpie
    pkgs.knot-dns

    pkgs.nil
    pkgs.nixpkgs-fmt

    pkgs.nodePackages.bash-language-server
    pkgs.shellcheck

    pkgs.devenv
  ];

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  programs.jq = {
    enable = true;
  };
}
