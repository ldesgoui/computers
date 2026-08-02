_:
{ pkgs, ... }: {
  home.packages = [
    pkgs.httpie
    pkgs.knot-dns

    pkgs.nil
    pkgs.nixpkgs-fmt

    pkgs.nls

    pkgs.bash-language-server
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
