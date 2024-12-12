{ config, ... }: {
  services.jellyfin = {
    enable = true;
  };

  services.jellyseerr = {
    enable = true;
  };

  services.radarr = {
    enable = true;
  };

  services.sonarr = {
    enable = true;
  };

  services.lidarr = {
    enable = true;
  };

  services.bazarr = {
    enable = true;
  };

  services.prowlarr = {
    enable = true;
  };

  zfs.datasets = {
    main._.enc._.media = {
      _.movies = {
        mountPoint = "/srv/movies";
      };

      _.series = {
        mountPoint = "/srv/series";
      };

      _.music = {
        mountPoint = "/srv/music";
      };
    };

    main._.enc._.services = {
      _.jellyfin._.data = {
        mountPoint = config.services.jellyfin.dataDir;
      };

      _.jellyfin._.cache = {
        mountPoint = config.services.jellyfin.cacheDir;
      };

      _.jellyseerr = {
        mountPoint = "/var/lib/jellyseerr"; # StateDirectory
      };

      _.radarr = {
        mountPoint = "/var/lib/radarr"; # Weird hardcode
      };

      _.sonarr = {
        mountPoint = "/var/lib/sonarr"; # Weird hardcode
      };

      _.lidarr = {
        mountPoint = "/var/lib/lidarr"; # Weird hardcode
      };

      _.bazarr = {
        mountPoint = "/var/lib/bazarr"; # Weird hardcode
      };

      _.prowlarr = {
        mountPoint = "/var/lib/prowlarr"; # StateDirectory
      };
    };
  };
}
