{ inputs, ... }:
{
  flake.nixosConfigurations.virt-mumble-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # inputs.agenix.nixosModules.default
      # inputs.agenix-rekey.nixosModules.default
      inputs.microvm.nixosModules.microvm

      ({ ... }: {
        microvm = {
          # hypervisor = "cloud-hypervisor";
          machineId = "c246757b-18a3-436e-adb2-475c5dde0923";
          registerWithMachined = true;
          systemSymlink = true;
          vsock.cid = 5;

          shares = [{
            proto = "virtiofs";
            tag = "ro-store";
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
          }];

          interfaces = [{
            type = "macvtap";
            id = "vm-c24675";
            mac = "02:ca:fe:c2:46:75";
            macvtap.link = "vlan100";
            macvtap.mode = "bridge";
          }];
        };

        system.stateVersion = "25.11";

        networking.hostName = "mumble-server";

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
            matchConfig.MacAddress = "02:ca:fe:c2:46:75";
            networkConfig = {
              Address = [ "10.100.194.70" ];
              Gateway = "10.100.0.1";
              DNS = [ "10.100.0.1" ];
              IPv6AcceptRA = true;
              DHCP = "no";
            };
          };
        };

        systemd.services.murmur = {
          restartIfChanged = false;
        };

        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };
      })
    ];
  };
}
