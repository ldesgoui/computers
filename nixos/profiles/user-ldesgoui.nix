{ pkgs, inputs, ... }: {
  users.users.ldesgoui = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    packages = [
      pkgs.git
      inputs.helix.packages.${pkgs.system}.helix
    ];
  };

  nix.settings.trusted-users = [ "ldesgoui" ];

  boot.zfs.datasets = {
    main._.enc._.users._.ldesgoui = {
      # We would prefer using `config.users.users.ldesgoui.home` here
      # but doing so causes an infinite recursion error.
      mountPoint = "/home/ldesgoui";
    };
  };
}
