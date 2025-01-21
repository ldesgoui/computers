{ self, ... }:
{ config, ... }: {
  imports = [ self.nixosModules.profiles-syncthing ];

  services.syncthing = {
    enable = true;
    settings = {
      folders.KeePass = {
        path = "/home/ldesgoui/.local/share/KeePass";
        devices = [ "soldier" "spy" ];
        ignorePerms = true;
      };
    };
  };

  systemd.user.tmpfiles.users.ldesgoui.rules =
    map (path: "z '${path}' 02770 ldesgoui ldesgoui-syncthing - -") [
      config.services.syncthing.settings.folders.KeePass.path
    ];

  systemd.services.syncthing.serviceConfig = {
    UMask = "0002";
  };

  users.groups.ldesgoui-syncthing.members = [ "ldesgoui" "syncthing" ];

  zfs.datasets.main._.enc._.users._.ldesgoui = {
    _.keepass = {
      mountPoint = config.services.syncthing.settings.folders.KeePass.path;
    };
  };
}
