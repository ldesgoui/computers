_: {
  perSystem = { config, lib, pkgs, inputs', ... }: {
    packages = {
      totem-firmware = inputs'.zmk-nix.legacyPackages.buildSplitKeyboard {
        name = "totem-firmware";

        src = pkgs.runCommand "totem-firmware-config" { } ''
          mkdir $out
          cp -r ${./totem} $out/config
        '';

        board = "seeeduino_xiao_ble";
        shield = "totem_%PART%";
        parts = [ "dongle" "left" "right" ];

        zephyrDepsHash = "sha256-SHiCGErcstMH9EbvbQROXIhxFEbMf3AungYu5YvqMEg=";
      };

      xiao-reset-firmware = inputs'.zmk-nix.legacyPackages.buildKeyboard {
        name = "xiao-reset-firmware";

        src = pkgs.runCommand "totem-firmware-config" { } ''
          mkdir $out
          cp -r ${./totem} $out/config
        '';

        board = "seeeduino_xiao_ble";
        shield = "settings_reset";

        zephyrDepsHash = "sha256-SHiCGErcstMH9EbvbQROXIhxFEbMf3AungYu5YvqMEg=";
      };
    };
  };
}
