{ self, ... }:
{ pkgs, ... }: {
  nix.buildMachines = [{
    hostName = "soldier";
    system = "x86_64-linux";

    sshUser = "nix-remote-builder";
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
    # This is such a dumb API
    publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUg4S2c5bVVJZThoM1JNalZKdFhrVFlLMWNIeHU1Wlg4S0hMLytFWGxMaE8=";

    maxJobs = 12;
    supportedFeatures = [
      "big-parallel"
      "kvm"
      "benchmark"
      "nixos-test"
    ];
  }];
}
