_:
{ lib, pkgs, ... }: {
  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrG1pOTv5Oki3p6jiqhb5ax99H6blhcL8EHvSd4DfyD";
  };

  users.users.ldesgoui = {
    extraGroups = [ "dialout" "podman" ];
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };
}
