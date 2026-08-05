{ lib, self, inputs, ... }: {
  flake.nixosConfigurations.sniper =
    let
      facter = lib.importJSON ./facter.json;
    in
    inputs.nixpkgs-unstable.lib.nixosSystem {
      inherit (facter) system;

      modules = [
        inputs.disko.nixosModules.default
        inputs.disko-zfs.nixosModules.default
        ./disko.nix

        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
        self.nixosModules.age-rekey-settings

        ./initrd.nix
        ./http.nix
        ./kanidm.nix
        ./mumble-server.nix

        {
          networking.hostName = "sniper";

          age.rekey = {
            hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvEJEu+uIurhLqOHdAguHN4yj7A+sADcTcWJ10HJsWI";
          };

          boot.kernelParams = [ "console=ttyS0" ];

          boot.loader = {
            systemd-boot = {
              enable = true;

              # Automatically drop the oldest configs,
              # mostly so that the ESP doesn't fill up too much
              configurationLimit = 3;
            };

            # There won't be another OS touching it so this is fine
            efi.canTouchEfiVariables = true;
          };

          boot.zfs = {
            devNodes = "/dev/disk/by-path"; # Scaleway didn't set serial number of virtio disks :(

            # We don't want to try unlocking everything on boot
            # as some of the keys are read from agenix secrets,
            # those are not available.
            requestEncryptionCredentials = [ "harvest/sniper" ];

            # This is the new recommended default
            forceImportRoot = false;
          };

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

            hostKeys = [{
              path = "/etc/ssh/host-keys/host_id25519";
              type = "ed25519";
            }];
          };

          system.stateVersion = "26.05"; # No touchie

          systemd.network = {
            networks."10-ens2" = {
              matchConfig.Name = "ens2";
              networkConfig = {
                DHCP = "ipv4";
              };
              ipv6AcceptRAConfig = {
                UseDNS = true;
                Token = "::8";
              };
            };
          };

          time.timeZone = "Europe/Paris";

          users = {
            mutableUsers = false; # Stateless users, but gotta provision passwords

            users.root = {
              initialPassword = "toor";
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK25ea20daUVvmTPmUL1nF/0DXEz/7tPBXOSerQNTf6+"
              ];
            };
          };
        }
      ];
    };
}
