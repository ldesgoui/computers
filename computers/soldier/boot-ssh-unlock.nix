{ config, ... }: {
  age.secrets.initrd_host_ssh_key = {
    rekeyFile = ./initrd_host_ssh_key.age;
    generator.script = "ssh-ed25519";
    path = "/boot/initrd_host_ssh_key";
    # We need this file to be available in initrd before the ZFS encrypted pools
    # have their keys loaded. Keeping it in cleartext is fine enough, we can't
    # really do better as far as I'm aware.
    # Hopefully this always gets written whenever we change the source secret.
    symlink = false;
  };

  boot.initrd.network = {
    enable = true;

    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [ config.age.secrets.initrd_host_ssh_key.path ];
      # TODO
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK25ea20daUVvmTPmUL1nF/0DXEz/7tPBXOSerQNTf6+"
      ];
    };

    postCommands = ''
      echo 'echo "- zfs load-keys -a && killall zfs"' >> /root/.profile
    '';
  };
}
