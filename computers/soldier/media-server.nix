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
  # FIXME: ^ sonarr causing a build error because of its deps
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-6.0.36"
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];

  services.lidarr = {
    enable = true;
  };

  services.bazarr = {
    enable = true;
  };

  services.prowlarr = {
    enable = true;
  };

  systemd.tmpfiles.rules = [
    "z /srv/movies 0755 jellyfin jellyfin - -"
    "z /srv/series 0755 jellyfin jellyfin - -"
    "z /srv/music 0755 jellyfin jellyfin - -"
    "z ${config.services.jellyfin.dataDir} 0755 jellyfin jellyfin - -"
    "z ${config.services.jellyfin.cacheDir} 0755 jellyfin jellyfin - -"
  ];

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
