{ self, ... }:
{
  nix.buildMachines = [{
    hostName = "soldier";
    system = "x86_64-linux";

    sshUser = "nix-remote-builder";
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
    publicHostKey = self.nixosConfigurations.soldier.config.age.rekey.hostPubkey;

    maxJobs = 12;
    supportedFeatures = [
      "big-parallel"
      "kvm"
      "benchmark"
      "nixos-test"
    ];
  }];
}
