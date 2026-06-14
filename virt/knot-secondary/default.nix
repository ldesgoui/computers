{ self, inputs, ... }:
{
  flake.nixosConfigurations.knot-secondary = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
      self.nixosModules.age-rekey-settings
      inputs.microvm.nixosModules.microvm
      self.nixosModules.microvm-nix-store-ro
      self.nixosModules.microvm-ssh
      self.nixosModules.microvm-vlan100 # TODO: force ipv6 ::2:53
      self.nixosModules.microvm-vsock-cid
      self.nixosModules.microvm-zfs-shares-guest

      ({ config, ... }: {
        networking.hostName = "knot-secondary";

        microvm = {
          machineId = "7f4b06cc-4b9c-486f-aa2f-e3adc65dfef4";
          registerWithMachined = true;
          systemSymlink = true;

          zfs = {
            datasets = {
              var = { mountPoint = "/var"; }; # Just in case
              nixos = { mountPoint = "/var/lib/nixos"; };
              systemd = { mountPoint = "/var/lib/systemd"; };

              knot = { mountPoint = "/var/lib/knot"; };
            };
          };
        };

        system.stateVersion = "26.05";

        age.rekey = {
          # hostPubkey = "";
        };

        age.secrets.xfr-tsig = {
          rekeyFile = ./xfr-tsig.age;
          generator.script = "knot-tsig";
          settings.id = "knot-secondary.xfr";
        };

        networking.firewall = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 ];
        };

        services.knot = {
          enable = true;

          keyFiles = [ config.age.secrets.xfr-tsig.path ];

          settings = {
            server = {
              automatic-acl = "on";
            };

            remote = [{
              id = "knot-primary";
              address = [ "2001:41d0:fc14:cafe::53" ];
              via = [ "2001:41d0:fc14:cafe::2:53" ];
              key = "knot-secondary.xfr";
            }];

            template = [{
              id = "secondary";
              master = "knot-primary";
            }];

            zone = [{
              domain = "catalog";
              template = "secondary";
              catalog-role = "interpret";
              catalog-template = "secondary";
            }];
          };
        };
      })
    ];
  };
}
