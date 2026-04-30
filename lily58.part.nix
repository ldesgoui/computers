_: {
  perSystem = { config, lib, pkgs, inputs', ... }: {
    packages = {
      lily58-firmware = inputs'.zmk-nix.legacyPackages.buildSplitKeyboard {
        name = "lily58-firmware";

        src = pkgs.runCommand "lily58-firmware-config" { } ''
          mkdir $out
          cp -r ${./lily58} $out/config
        '';

        board = "nice_nano_v2";
        shield = "lily58_%PART%";
        parts = [ "left" "right" ];

        zephyrDepsHash = "sha256-SHiCGErcstMH9EbvbQROXIhxFEbMf3AungYu5YvqMEg=";
      };
    };
  };
}
