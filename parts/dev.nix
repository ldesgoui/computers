{ self, ... }: {
  perSystem = { lib, pkgs, ... }: {
    checks.nixpkgs-fmt = pkgs.runCommand "nixpkgs-fmt-check" { } ''
      ${lib.getExe pkgs.nixpkgs-fmt} --check ${lib.escapeShellArg self}
      touch $out
    '';

    devShells.default = pkgs.mkShellNoCC {
      packages = [
        pkgs.helix
        (pkgs.runCommand "helix-vi-aliases" { } ''
          mkdir -p "$out/bin"
          for exe in vi vim nvim; do
            ln -s ${lib.getExe pkgs.helix} "$out/bin/$exe"
          done
        '')

        pkgs.nil
        pkgs.nixpkgs-fmt

        pkgs.nodePackages.bash-language-server
        pkgs.shellcheck

        pkgs.taplo
      ];
    };

    formatter = pkgs.nixpkgs-fmt;
  };
}
