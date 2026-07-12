{
  flake.nixosModules.microvm-users = {
    users.mutableUsers = false;

    users.users.root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK25ea20daUVvmTPmUL1nF/0DXEz/7tPBXOSerQNTf6+ ldesgoui@scout"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEKTIdCTmYMk+5MxwWLhH4YNDwY2zXIuEvnyzIrXikOe ldesgoui@soldier"
      ];
    };
  };
}
