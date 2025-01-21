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
        pkgs.age-plugin-yubikey
        config.agenix-rekey.package
      ];
    };

    formatter = pkgs.nixpkgs-fmt;
  };
}
