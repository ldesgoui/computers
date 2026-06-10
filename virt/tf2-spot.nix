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
      self.nixosModules.microvm-vlan100
      self.nixosModules.microvm-vsock-cid
      self.nixosModules.microvm-zfs-shares-guest

      ({ config, ... }: {
        networking.hostName = "tf2-spot";

        microvm = {
          machineId = "a821c19f-1d8b-4338-ba10-55acae265820";
          registerWithMachined = true;
          systemSymlink = true;

          zfs = {
            datasets = {
              var = { mountPoint = "/var"; }; # Just in case
              nixos = { mountPoint = "/var/lib/nixos"; };
              systemd = { mountPoint = "/var/lib/systemd"; };
            };
          };
        };

        system.stateVersion = "26.05";

        age.rekey = {
          # hostPubkey = "";
        };
      })
    ];
  };
}
