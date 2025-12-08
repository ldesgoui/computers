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
        shield = "splitkb_aurora_corne_%PART%";

        enableZmkStudio = true;

        zephyrDepsHash = "sha256-SHiCGErcstMH9EbvbQROXIhxFEbMf3AungYu5YvqMEg=";
      };
    };
  };
}
