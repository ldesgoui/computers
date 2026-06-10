{
  flake.nixosModules.microvm-ssh = {
    microvm = {
      zfs = {
        datasets = {
          ssh-host-keys = { mountPoint = "/etc/ssh/host-keys"; };
        };
      };
    };

    services.openssh = {
      enable = true;

      hostKeys = [{
        path = "/etc/ssh/host-keys/host_id25519";
        type = "ed25519";
      }];
    };
  };
}
