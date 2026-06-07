{ lib, inputs, ... }: {
  flake.nixosConfigurations.heavy =
    let
      facter = lib.importJSON ./facter.json;
    in
    inputs.nixpkgs-unstable.lib.nixosSystem {
      inherit (facter) system;

      modules = [
        inputs.disko.nixosModules.default
        inputs.disko-zfs.nixosModules.default
        ./disko.nix
        ./initrd.nix
        {
          boot.loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };

          boot.zfs.forceImportRoot = false;

          hardware.facter.report = facter;

          networking = {
            # Use the same default hostID as the NixOS install ISO and nixos-anywhere.
            # This allows us to import zfs pool without using a force import.
            # ZFS has this as a safety mechanism for networked block storage (ISCSI), but
            # in practice we found it causes more breakages like unbootable machines,
            # while people using ZFS on ISCSI is quite rare.
            hostId = "8425e349";

            hostName = "heavy";
            useNetworkd = true;
          };

          nix = {
            channel.enable = false;

            nixPath = lib.mkForce [
              "nixpkgs=${inputs.nixpkgs-unstable}"
              "nixos=${inputs.nixpkgs-unstable}"
            ];

            optimise.automatic = true;

            registry = {
              nixos.flake = inputs.nixpkgs-unstable;
            };

            settings = {
              experimental-features = [ "nix-command" "flakes" ];
              trusted-users = [ "@wheel" ];
            };
          };

          system.stateVersion = "25.11";

          time.timeZone = "Europe/Paris";

          users = {
            mutableUsers = false;
            users.root.initialPassword = "toor";
          };
        }
      ];
    };
}
