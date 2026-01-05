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
        path = "/srv/home/Android Camera";
        devices = [ "spy" ];
        ignorePerms = true;
      };

      folders."Android Downloads" = {
        id = "30td3-ltwk1";
        path = "/srv/home/Android Downloads";
        devices = [ "spy" ];
        ignorePerms = true;
      };

      folders."Android Pictures" = {
        id = "5dron-43amb";
        path = "/srv/home/Android Pictures";
        devices = [ "spy" ];
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

  zfs.datasets.main.enc.users.ldesgoui = {
    keepass = {
      mountPoint = config.services.syncthing.settings.folders.KeePass.path;
    };
  };
}
