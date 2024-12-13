{ self, ... }: {
  perSystem = { config, lib, pkgs, ... }: {
    checks.nixpkgs-fmt = pkgs.runCommand "nixpkgs-fmt-check" { } ''
      ${lib.getExe pkgs.nixpkgs-fmt} --check ${lib.escapeShellArg self}
      touch $out
    '';

    devShells.default = pkgs.mkShellNoCC {
      packages = [
        pkgs.nil
        pkgs.nixpkgs-fmt

        pkgs.nodePackages.bash-language-server
        pkgs.shellcheck

        pkgs.taplo

        pkgs.rage
        config.agenix-rekey.package
      ];

      env.AGENIX_REKEY_ADD_TO_GIT = "true";
    };

    formatter = pkgs.nixpkgs-fmt;
  };
}
