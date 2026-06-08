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
        inputs.microvm.nixosModules.host
        ./disko.nix
        ./initrd.nix
        {
          boot.loader = {
            systemd-boot = {
              enable = true;

              # Automatically drop the oldest configs,
              # mostly so that the ESP doesn't fill up too much
              configurationLimit = 10;
            };

            # There won't be another OS touching it so this is fine
            efi.canTouchEfiVariables = true;
          };

          # This is the new recommended default
          boot.zfs.forceImportRoot = false;

          documentation = {
            enable = false;
            doc.enable = false;
            info.enable = false;
            man.enable = false;
            nixos.enable = false;
          };

          environment = {
            stub-ld.enable = false; # I don't need warnings about out-of-nix binaries
          };

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
            channel.enable = false; # We never use nix channels

            nixPath = lib.mkForce [
              # In the rare cases where we evaluate <nixpkgs> or <nixos>
              "nixpkgs=${inputs.nixpkgs-unstable}"
              "nixos=${inputs.nixpkgs-unstable}"
            ];

            optimise.automatic = true; # Run dedup once a day

            registry = {
              # This is to speed up `nix <action> nixos#<whatever>`
              # If I want something fresher, I usually go for nixpkgs#<whatever>
              nixos.flake = inputs.nixpkgs-unstable;
            };

            settings = {
              experimental-features = [ "nix-command" "flakes" ];
              trusted-users = [ "@wheel" ];
            };
          };

          services.openssh = {
            enable = true;
          };

          system.stateVersion = "25.11"; # No touchie

          systemd.network = {
            networks."10-eno3-vlan100" = {
              matchConfig.Name = "eno3";
              networkConfig.VLAN = "vlan100";
            };

            netdevs."20-vlan100" = {
              netdevConfig = {
                Kind = "vlan";
                Name = "vlan100";
              };
              vlanConfig.ID = "100";
            };
          };

          time.timeZone = "Europe/Paris";

          users = {
            mutableUsers = false; # Stateless users, but gotta provision passwords
            users.root.initialPassword = "toor";
          };
        }
      ];
    };
}
