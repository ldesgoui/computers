{ self, inputs, ... }:
{
  flake.nixosConfigurations.kanidm = inputs.nixpkgs.lib.nixosSystem {
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
        networking.hostName = "kanidm";
        system.stateVersion = "26.05";

        microvm = {
          machineId = "acf436d7-0a3e-4a26-a69a-5aa3b01ee940";
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

              kanidm = {
                mountPoint = "/var/lib/kanidm";
                options = {
                  compression = "off";
                  recordsize = "64K";
                };
              };
            };
          };
        };

        age.rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzHK/cBnO6kTN/ALUmn28xSDu47/tkS+r7RarjkxDqC";
        };

        age.secrets = {
          kanidm-admin-password = {
            rekeyFile = ./kanidm-admin-password.age;
            owner = "kanidm";
            generator.script = "passphrase";
          };

          kanidm-idm-admin-password = {
            rekeyFile = ./kanidm-idm-admin-password.age;
            owner = "kanidm";
            generator.script = "passphrase";
          };
        };

        networking.firewall = {
          allowedTCPPorts = [ 80 443 ];
        };

        security.acme = {
          acceptTerms = true;
          defaults = {
            email = "ldesgoui@gmail.com";
            webroot = "/var/lib/acme/acme-challenge/";
          };
        };

        security.acme.certs."auth.lde.sg" = {
          group = "kanidm";
          reloadServices = [ "kanidm" ];
        };

        services.caddy = {
          enable = true;

          globalConfig = ''
            servers {
              listener_wrappers {
                proxy_protocol {
                  allow 2001:41d0:fc14:cafe:0:ff:fe81:4a0 # http-proxy
                }
                tls
              }
            }
          '';

          # For ACME
          virtualHosts = {
            "http://auth.lde.sg" = {
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

        services.kanidm = {
          package = pkgs.kanidmWithSecretProvisioning_1_10;

          client = {
            enable = true;
            settings = {
              uri = "https://auth.lde.sg";
            };
          };

          server = {
            enable = true;
            settings =
              let
                certDir = config.security.acme.certs."auth.lde.sg".directory;
              in
              {
                bindaddress = "[::]:443";

                domain = "auth.lde.sg";
                origin = "https://auth.lde.sg";

                tls_key = "${certDir}/key.pem";
                tls_chain = "${certDir}/full.pem";

                db_fs_type = "zfs";

                http_client_address_info.proxy-v2 = [
                  "2001:41d0:fc14:cafe:0:ff:fe81:4a0" # http-proxy
                ];
              };
          };

          provision = {
            enable = true;
            autoRemove = false;

            adminPasswordFile = config.age.secrets.kanidm-admin-password.path;
            idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin-password.path;
          };
        };

        time.timeZone = "Europe/Paris";
      })
    ];
  };
}
