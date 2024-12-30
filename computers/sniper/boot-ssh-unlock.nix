{ config, ... }: {
  age.secrets.initrd_host_ssh_key = {
    file = ./initrd_host_ssh_key.age;
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
    };

    postCommands = ''
      echo 'echo "- zfs load-key -a && killall zfs"' >> /root/.profile
    '';
  };
}
