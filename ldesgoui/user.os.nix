_:
{ config, ... }: {
  age.secrets.ldesgoui-password = {
    rekeyFile = ./ldesgoui-password.age;
    generator.script = _: "mkpasswd -m sha-512";
  };

  users.users.ldesgoui = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.ldesgoui-password.path;
    extraGroups = [ "wheel" ];

    openssh = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK25ea20daUVvmTPmUL1nF/0DXEz/7tPBXOSerQNTf6+ ldesgoui@scout"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEKTIdCTmYMk+5MxwWLhH4YNDwY2zXIuEvnyzIrXikOe ldesgoui@soldier"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUtSdGOMvVecz0iJCx/IQxDxYEC6+TifOIF2wO+eRrf ldesgoui@sniper"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGuoIJZbzmxMq+noT7CGcQ8WxhtJN9dJeQ6HhTtPYsAy ldesgoui@recovery"
      ];
    };
  };

  zfs.datasets = {
    main._.enc._.users._.ldesgoui = {
      # We would prefer using `config.users.users.ldesgoui.home` here
      # but doing so causes an infinite recursion error.
      mountPoint = "/home/ldesgoui";
    };
  };
}
