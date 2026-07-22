{ self, inputs, ... }:
{
  flake.nixosConfigurations.websites = inputs.nixpkgs.lib.nixosSystem {
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

      ({ config, pkgs, ... }: {
        networking.hostName = "websites";
        system.stateVersion = "26.05";

        microvm = {
          machineId = "07ebe942-3a0c-4f39-b5cb-13614fed30a1";
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
            };
          };
        };

        age.rekey = {
          # hostPubkey = "";
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
            "lde.sg" = {
              extraConfig = ''
                file_server {
                  root ${../../src/lde.sg}
                }
              '';
            };

            "ldesgoui.xyz" = {
              extraConfig = ''
                redir https://lde.sg{uri}
              '';
            };

            "piss-your.se" = {
              extraConfig = ''
                file_server {
                  root ${../../src/piss-your.se}
                }
                redir / /f 301
              '';
            };
          };
        };

        time.timeZone = "Europe/Paris";
      })
    ];
  };
}
