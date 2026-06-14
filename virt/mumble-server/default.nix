{ self, inputs, ... }:
{
  flake.nixosConfigurations.mumble-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
      self.nixosModules.age-rekey-settings
      inputs.microvm.nixosModules.microvm
      self.nixosModules.microvm-nix-store-ro
      self.nixosModules.microvm-ssh
      self.nixosModules.microvm-vlan100
      self.nixosModules.microvm-vsock-cid
      self.nixosModules.microvm-zfs-shares-guest

      ({ config, ... }: {
        networking.hostName = "mumble-server";

        microvm = {
          machineId = "c246757b-18a3-436e-adb2-475c5dde0923";
          registerWithMachined = true;
          systemSymlink = true;

          zfs = {
            datasets = {
              var = { mountPoint = "/var"; }; # Just in case
              nixos = { mountPoint = "/var/lib/nixos"; };
              systemd = { mountPoint = "/var/lib/systemd"; };

              mumble-server = {
                mountPoint = "/var/lib/murmur";
              };
            };
          };
        };

        system.stateVersion = "26.05";

        users.users.root.password = "toor";

        age.rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBlbiOZ77MveihFLNG8T5eGLcx5+IG1qnTwNpAzPkZD";
        };

        age.secrets.murmur-password = {
          rekeyFile = ./murmur-password.age;
        };

        age.secrets.murmur-env = {
          rekeyFile = ./murmur-env.age;
          generator = {
            dependencies = { PASSWORD = config.age.secrets.murmur-password; };
            script = "deps-to-env";
          };
        };

        services.murmur = {
          enable = true;

          environmentFile = config.age.secrets.murmur-env.path;

          openFirewall = true;

          registerName = "epic server of cool";

          bandwidth = 558000;
          imgMsgLength = 1024 * 1024 * 10;

          password = "$PASSWORD";

          welcometext = builtins.replaceStrings [ "\n" ] [ "<br />" ] ''
            hi
          '';

          extraConfig = ''
            rememberchannelduration=3600
          '';
        };
      })
    ];
  };
}
