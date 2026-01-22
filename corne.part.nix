_: {
  perSystem = { config, lib, pkgs, inputs', ... }: {
    packages = {
      corne-firmware = inputs'.zmk-nix.legacyPackages.buildSplitKeyboard {
        name = "corne-firmware";

        src = pkgs.runCommand "corne-firmware-config" { } ''
          mkdir $out
          cp -r ${./corne} $out/config
        '';

        board = "nice_nano_v2";
        shield = "corne_%PART%";
        parts = [ "dongle" "p_left" "p_right" ];

        zephyrDepsHash = "sha256-SHiCGErcstMH9EbvbQROXIhxFEbMf3AungYu5YvqMEg=";
      };

      reset-firmware = inputs'.zmk-nix.legacyPackages.buildKeyboard {
        name = "reset-firmware";

        src = pkgs.runCommand "corne-firmware-config" { } ''
          mkdir $out
          cp -r ${./corne} $out/config
        '';

        board = "nice_nano_v2";
        shield = "settings_reset";

        zephyrDepsHash = "sha256-SHiCGErcstMH9EbvbQROXIhxFEbMf3AungYu5YvqMEg=";
      };
    };
  };
}
