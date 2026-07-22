{ self, inputs, ... }:
{
  flake.nixosConfigurations.vaultwarden = inputs.nixpkgs.lib.nixosSystem {
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

      ({ lib, config, ... }: {
        networking.hostName = "vaultwarden";
        system.stateVersion = "26.05";

        microvm = {
          machineId = "ca5885a4-b586-4233-a029-83215a8eded7";
          registerWithMachined = true;
          systemSymlink = true;

          zfs = {
            root.options = {
              # Manual key input
              encryption = "on";
              keyformat = "passphrase";

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

              vaultwarden = {
                mountPoint = "/var/lib/vaultwarden";
              };

              "vaultwarden/db" = {
                mountPoint = "/var/lib/vaultwarden/db";

                options = {
                  recordsize = "64K";
                };
              };
            };
          };
        };

        age.rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoEC34X3M6zZol+67RZYBd6ckl8247DgcEHQfFcNxhX";
        };

        age.secrets.vaultwarden-oidc-secret = {
          rekeyFile = ./vaultwarden-oidc-secret.age;
          generator.script = "alnum";
        };

        age.secrets.vaultwarden-smtp-password = {
          rekeyFile = ./vaultwarden-smtp-password.age;
          generator.script = "alnum";
        };

        age.secrets.vaultwarden-installation-key = {
          rekeyFile = ./vaultwarden-installation-key.age;
        };

        age.secrets.vaultwarden-env = {
          rekeyFile = ./vaultwarden-env.age;
          generator = {
            dependencies = {
              SSO_CLIENT_SECRET = config.age.secrets.vaultwarden-oidc-secret;
              SMTP_PASSWORD = config.age.secrets.vaultwarden-smtp-password;
              PUSH_INSTALLATION_KEY = config.age.secrets.vaultwarden-installation-key;
            };
            script = "deps-to-env";
          };
        };

        services.caddy = {
          enable = true;
          openFirewall = true;

          # TODO: Harden by only allowing the specific IPv6 of virt/http-proxy?
          globalConfig = ''
            email ldesgoui@gmail.com
            servers {
              listener_wrappers {
                proxy_protocol {
                  allow 2001:41d0:fc14:cafe::1/64
                }
                tls
              }
            }
          '';

          virtualHosts = {
            "passwords.lde.sg" = {
              extraConfig = ''
                reverse_proxy [::1]:${toString config.services.vaultwarden.config.ROCKET_PORT} {
                  header_up X-Real-IP {remote_host}
                }
              '';
            };
          };
        };

        services.vaultwarden = {
          enable = true;

          config = {
            ROCKET_ADDRESS = "::1";
            ROCKET_PORT = 8222;

            DATABASE_URL = "/var/lib/vaultwarden/db/vaultwarden.sqlite3";
            ICON_CACHE_FOLDER = "/var/cache/vaultwarden/icon-cache";
            TMP_FOLDER = "/tmp/vaultwarden"; # PrivateTmp is already set

            DOMAIN = "https://passwords.lde.sg";

            WEB_VAULT_ENABLED = true;

            SIGNUPS_ALLOWED = false;

            # SSO_ENABLED = true;
            # SSO_ONLY = true;
            # SSO_AUTHORITY = "https://auth.lde.sg/oauth2/openid/vaultwarden";
            # SSO_CLIENT_ID = "vaultwarden";

            # SMTP_HOST = "mx1.lde.sg";
            # SMTP_SECURITY = "force_tls";
            # SMTP_PORT = 465;
            # SMTP_FROM = "vaultwarden@lde.sg";
            # SMTP_USERNAME = "vaultwarden";

            # PUSH_ENABLED = true;
            # PUSH_INSTALLATION_ID = "04108ee1-9978-4e67-b5f4-b27100e87777";
            # PUSH_RELAY_URI = "https://api.bitwarden.eu";
            # PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";

            SENDS_ALLOWED = false;
          };

          environmentFile = config.age.secrets.vaultwarden-env.path;
        };

        systemd.services.vaultwarden = {
          serviceConfig = {
            CacheDirectory = "vaultwarden";
            CacheDirectoryMode = "0700";
          };
        };

        time.timeZone = "Europe/Paris";
      })
    ];
  };
}
