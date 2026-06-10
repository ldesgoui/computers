{ self, inputs, ... }:
{
  flake.nixosConfigurations.mumble-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
      self.nixosModules.age-rekey-settings
      inputs.microvm.nixosModules.microvm
      self.nixosModules.microvm-zfs-shares-guest

      ({ ... }: {
        networking.hostName = "mumble-server";

        microvm = {
          # hypervisor = "cloud-hypervisor";
          machineId = "c246757b-18a3-436e-adb2-475c5dde0923";
          registerWithMachined = true;
          systemSymlink = true;
          vsock.cid = 5;

          interfaces = [{
            type = "macvtap";
            id = "vm-c24675";
            mac = "02:ca:fe:c2:46:75";
            macvtap.link = "vlan100";
            macvtap.mode = "bridge";
          }];

          shares = [{
            proto = "virtiofs";
            tag = "ro-store";
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
          }];

          zfs = {
            datasets = {
              var = { mountPoint = "/var"; }; # Just in case
              nixos = { mountPoint = "/var/lib/nixos"; };
              systemd = { mountPoint = "/var/lib/systemd"; };
              ssh-host-keys = { mountPoint = "/etc/ssh/host-keys"; };

              mumble-server = {
                mountPoint = "/var/lib/murmur";
              };
            };
          };
        };

        system.stateVersion = "25.11";

        age.rekey = {
          # hostPubkey = "";
        };

        age.secrets.murmur_password = {
          rekeyFile = ../soldier/murmur_password.age;
        };

        users.users.root.password = "toor";

        services.murmur = {
          enable = true;

          openFirewall = true;

          registerName = "da server >;D";

          bandwidth = 558000;
          imgMsgLength = 1024 * 1024 * 10;

          password = "test";

          welcometext = builtins.replaceStrings [ "\n" ] [ "<br />" ] ''
            Wow! It's you! Nice!
            The server has moved hosts :)
          '';

          extraConfig = ''
            rememberchannelduration=3600
          '';
        };

        systemd.network = {
          networks."10-vlan100" = {
            matchConfig.MACAddress = "02:00:00:00:c2:46";
            networkConfig = {
              Address = [ "10.100.194.70/16" ];
              Gateway = "10.100.0.1";
              DNS = [ "10.100.0.1" ];
              IPv6AcceptRA = true;
              DHCP = "no";
            };
          };
        };

        services.openssh = {
          enable = true;

          hostKeys = [{
            path = "/etc/ssh/host-keys/host_id25519";
            type = "ed25519";
          }];

          settings.PermitRootLogin = "yes";
        };
      })
    ];
  };
}
