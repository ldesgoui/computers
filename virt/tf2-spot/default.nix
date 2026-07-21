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

      inputs.tf2-spot.nixosModules.websites

      ({ lib, pkgs, config, ... }: {
        networking.hostName = "tf2-spot";
        system.stateVersion = "26.05";

        microvm = {
          machineId = "a821c19f-1d8b-4338-ba10-55acae265820";
          registerWithMachined = true;
          systemSymlink = true;

          vcpu = 4;
          mem = 12885; # 12GiB

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

              # caddy doesn't write files
              # toplevel doesn't write files
              # fantasy doesn't write files
              postgresql = {
                mountPoint = "/var/lib/postgresql";
                options = {
                  # https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Workload%20Tuning.html#postgresql
                  recordsize = "32K"; # This would be 8K to match PG's record size, but compression is enabled
                  primarycache = "metadata"; # We probably have enough memory, but let's just trust PG's cache
                };
              };
              # sqitch doesn't write files
              # postgrest doesn't write files
              # TODO: mathesar writes media i guess
            };
          };

          volumes = [{
            # virtiofs is not good enough to do funny container stuff on I guess
            image = "var-lib-podman-mathesar.img";
            mountPoint = "/var/lib/podman-mathesar";
            size = 8 * 1024;
          }];
        };

        age.rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFsth5ox8QM1wCt1HMUg0Ba34BguJlgryKUko5HRYY1";
        };

        age.secrets.fantasy-secret-key = {
          rekeyFile = ./fantasy-secret-key.age;
          generator.script = "alnum";
        };

        age.secrets.fantasy-env = {
          rekeyFile = ./fantasy-env.age;
          generator = {
            dependencies = {
              FLASK_SECRET_KEY = config.age.secrets.fantasy-secret-key;
              FLASK_JWT_SECRET = config.age.secrets.postgrest-jwt-secret;
            };
            script = "deps-to-env";
          };
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

          owner = "mathesar";
        };

        services.caddy = {
          # TODO: Harden by only allowing the specific IPv6 of virt/http-proxy?
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

          # For ACME
          virtualHosts = {
            "http://tf2.spot" = {
              serverAliases = [
                "http://fantasy.tf2.spot"
                "http://postgrest.tf2.spot"
                "http://mathesar.tf2.spot"
              ];

              extraConfig = ''
                handle /.well-known/acme-challenge/* {
                  root * /var/lib/acme/acme-challenge/
                  file_server
                }

                handle {
                  redir https://{host}{uri}
                }
              '';
            };
          };
        };

        services.postgresql = {
          settings = {
            # https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Workload%20Tuning.html#postgresql
            full_page_writes = "off";
          };
        };

        security.acme = {
          acceptTerms = true;
          defaults = {
            email = "ldesgoui@gmail.com";
            webroot = "/var/lib/acme/acme-challenge/";
          };
        };

        tf2-spot = {
          toplevel = {
            enable = true;
          };

          fantasy = {
            enable = true;

            domain = "fantasy.localhost";
            tls = false;

            envFile = config.age.secrets.fantasy-env.path;
          };

          postgresql = {
            enable = true;
          };

          sqitch = {
            enable = true;
          };

          postgrest = {
            enable = true;

            domain = "postgrest.localhost";
            tls = false;

            jwtSecretFile = config.age.secrets.postgrest-jwt-secret.path;
          };

          mathesar = {
            enable = true;
            version = "0.12.0";
            envFile = config.age.secrets.mathesar-env.path;
          };
        };

        time.timeZone = "Europe/Paris";
      })
    ];
  };
}
