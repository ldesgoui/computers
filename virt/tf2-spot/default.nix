{ self, inputs, ... }:
{
  flake.nixosConfigurations.tf2-spot = inputs.nixpkgs.lib.nixosSystem {
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

      inputs.tf2-spot.nixosModules.websites

      ({ config, ... }: {
        networking.hostName = "tf2-spot";
        system.stateVersion = "26.05";

        microvm = {
          machineId = "a821c19f-1d8b-4338-ba10-55acae265820";
          registerWithMachined = true;
          systemSymlink = true;

          zfs = {
            root.encryption-passphrase-age-rekeyFile = ./zfs-encryption-passphrase.age;

            datasets = {
              var = { mountPoint = "/var"; }; # Just in case
              nixos = { mountPoint = "/var/lib/nixos"; };
              systemd = { mountPoint = "/var/lib/systemd"; };

              # caddy doesn't write files
              # toplevel doesn't write files
              # fantasy doesn't write files
              postgresql = {
                mountPoint = "/var/lib/postgresql";
                # TODO: postgresql tweaks
              };
              # sqitch doesn't write files
              # postgrest doesn't write files
              # TODO: mathesar writes media i guess
              # TODO: podman writes images that we don't care about
            };
          };
        };

        age.rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFsth5ox8QM1wCt1HMUg0Ba34BguJlgryKUko5HRYY1";
        };

        age.secrets.postgrest-jwt-secret = {
          rekeyFile = ./postgrest-jwt-secret.age;
          generator.script = "alnum";
        };

        age.secrets.mathesar-secret = {
          rekeyFile = ./mathesar-secret.age;
          generator.script = "alnum";
        };

        age.secrets.mathesar-env = {
          rekeyFile = ./mathesar-env.age;
          generator = {
            dependencies = {
              SECRET_KEY = config.age.secrets.mathesar-secret;
            };
            script = "deps-to-env";
          };
        };

        services.caddy = {
          # TODO: Harden by only allowing the specific IPv6 of virt/http-proxy
          globalConfig = ''
            servers {
              listener_wrappers {
                proxy_protocol {
                  allow 2001:41d0:fc14:cafe::1/64
                }
                tls
              }
            }
          '';

        };

        tf2-spot = {
          toplevel = {
            enable = true;
          };

          fantasy = {
            enable = true;
          };

          postgresql = {
            enable = true;
          };

          sqitch = {
            enable = true;
          };

          postgrest = {
            enable = true;
            jwtSecretFile = config.age.secrets.postgrest-jwt-secret.path;
          };

          mathesar = {
            enable = true;
            version = "0.12.0";
            envFile = config.age.secrets.mathesar-env.path;
          };
        };
      })
    ];
  };
}
