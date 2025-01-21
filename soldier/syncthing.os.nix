{ self, ... }:
{ config, ... }: {
  imports = [ self.nixosModules.profiles-syncthing ];

  services.syncthing = {
    enable = true;
    settings = {
      folders.KeePass = {
        path = "/home/ldesgoui/.local/share/KeePass";
        devices = [ "scout" "spy" ];
        ignorePerms = true;
      };

      folders."Android Camera" = {
        id = "pixel_6_ukgq-photos";
        path = "/home/ldesgoui/Android Camera";
        devices = [ "spy" ];
        ignorePerms = true;
      };
    };
  };

  systemd.user.tmpfiles.users.ldesgoui.rules =
    map (path: "z '${path}' 02770 ldesgoui ldesgoui-syncthing - -") [
      config.services.syncthing.settings.folders.KeePass.path
      config.services.syncthing.settings.folders."Android Camera".path
    ];

  systemd.services.syncthing.serviceConfig = {
    UMask = "0002";
  };

  users.groups.ldesgoui-syncthing.members = [ "ldesgoui" "syncthing" ];

  zfs.datasets.main._.enc._.users._.ldesgoui = {
    _.android-camera = {
      mountPoint = config.services.syncthing.settings.folders."Android Camera".path;
    };

    _.keepass = {
      mountPoint = config.services.syncthing.settings.folders.KeePass.path;
    };
  };
}
