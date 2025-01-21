_:
{ pkgs, ... }: {
  home.packages = [
    pkgs.httpie
    pkgs.knot-dns

    pkgs.nil
    pkgs.nixpkgs-fmt

    pkgs.nodePackages.bash-language-server
    pkgs.shellcheck
  ];

  programs.jq = {
    enable = true;
  };
}
