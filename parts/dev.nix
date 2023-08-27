{ self, ... }: {
  perSystem = { lib, pkgs, inputs', ... }: {
    checks.nixpkgs-fmt = pkgs.runCommand "nixpkgs-fmt-check" { } ''
      ${lib.getExe pkgs.nixpkgs-fmt} --check ${lib.escapeShellArg self}
      touch $out
    '';

    devShells.default = pkgs.mkShellNoCC {
      packages = [
        inputs'.helix.packages.helix
        (pkgs.runCommand "helix-vi-aliases" { } ''
          mkdir -p "$out/bin"
          for exe in vi vim nvim; do
            ln -s ${lib.getExe inputs'.helix.packages.helix} "$out/bin/$exe"
          done
        '')

        inputs'.nil.packages.nil
        pkgs.nixpkgs-fmt

        pkgs.nodePackages.bash-language-server
        pkgs.shellcheck

        pkgs.taplo
      ];
    };

    formatter = pkgs.nixpkgs-fmt;
  };
}
