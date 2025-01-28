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
  };

  zfs.datasets = {
    main._.enc._.users._.ldesgoui = {
      # We would prefer using `config.users.users.ldesgoui.home` here
      # but doing so causes an infinite recursion error.
      mountPoint = "/home/ldesgoui";
    };
  };
}
