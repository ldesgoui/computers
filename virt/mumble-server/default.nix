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
      self.nixosModules.microvm-users
      self.nixosModules.microvm-vlan100
      self.nixosModules.microvm-vsock-cid
      self.nixosModules.microvm-zfs-shares-guest
      self.nixosModules.acme-tsig

      ({ config, ... }: {
        networking.hostName = "mumble-server";
        system.stateVersion = "26.05";

        microvm = {
          machineId = "c246757b-18a3-436e-adb2-475c5dde0923";
          registerWithMachined = true;
          systemSymlink = true;

          zfs = {
            root.encryption-passphrase-age-rekeyFile = ./zfs-encryption-passphrase.age;

            root.options = {
              recordsize = "1M";

              compression = "zstd-3"; # lil harder than lz4

              acltype = "posix";
              atime = "off"; # don't care about access times
              dnodesize = "auto"; # more efficient than legacy
              xattr = "sa"; # enhances perf for acltype=posix and dnodesize=auto

              utf8only = "on";
              normalization = "formD";
            };

            datasets = {
              var = { mountPoint = "/var"; }; # Just in case
              nixos = { mountPoint = "/var/lib/nixos"; };
              systemd = { mountPoint = "/var/lib/systemd"; };

              mumble-server = {
                mountPoint = "/var/lib/murmur";
                options = {
                  recordsize = "64K";
                };
              };
            };
          };
        };

        age.rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA/ZEvhGwHQ1pfDMeNYZ4vm0A6QJfKW+s27STqlvuc6Z";
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

        security.acme.certs."cool-zone.lde.sg" = {
          extraDomainNames = [
            "soldier.wi.lde.sg"
            "mumble.ldesgoui.xyz"
          ];

          group = "murmur";
        };

        services.murmur = {
          enable = true;

          environmentFile = config.age.secrets.murmur-env.path;
          # tls.useACMEHost = "cool-zone.lde.sg";

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

        systemd.services.murmur.reload = "kill -USR1 $MAINPID";

        time.timeZone = "Europe/Paris";
      })
    ];
  };
}
