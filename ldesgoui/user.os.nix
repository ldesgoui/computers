_:
{
  users.users.ldesgoui = {
    isNormalUser = true;
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
