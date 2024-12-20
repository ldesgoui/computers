{ config, inputs, ... }: {
  flake.nixosConfigurations = {
    soldier = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./nixos.nix
        ./hardware.nix
        ./storage.nix

        ./nginx.nix

        ./kanidm.nix

        ./headscale.nix
        ./tailscale.nix
        ./wireguard-headscale-direct.nix

        ./media-server.nix
        ./jellyfin.nix
        ./jellyseerr.nix
        ./radarr.nix
        ./sonarr.nix
        ./lidarr.nix
        ./bazarr.nix
        ./prowlarr.nix
        ./transmission.nix

        ../../nixos/zfs.nix
        ../../nixos/ldesgoui.nix
        ../../nixos/nginx-reverse-pre-tls.nix

        ../../nixos/profiles/defaults.nix
        ../../nixos/profiles/acme.nix
        ../../nixos/profiles/nix.nix
        ../../nixos/profiles/zfs-datasets.nix

        config.flake.nixosModules.flake-inputs
        config.flake.nixosModules.age-rekey-settings

        inputs.home-manager.nixosModules.home-manager

        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
      ] ++ builtins.attrValues {
        inherit (inputs.nixos-hardware.nixosModules)
          common-cpu-amd
          common-cpu-amd-pstate
          common-gpu-amd
          common-pc
          common-pc-ssd
          ;
      };
    };
  };
}
