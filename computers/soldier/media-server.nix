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

  services.transmission = {
    enable = true;
    openPeerPorts = true;

    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = false;
    };
  };

  systemd.tmpfiles.settings."20-media-server" =
    let
      z = mode: user: group: { z = { inherit mode user group; }; };
    in
    {
      "/srv/movies" = z "0775" "root" "media";
      "/srv/series" = z "0775" "root" "media";
      "/srv/music" = z "0775" "root" "media";

      ${config.services.jellyfin.dataDir} = z "0755" "jellyfin" "jellyfin";
      ${config.services.jellyfin.cacheDir} = z "0755" "jellyfin" "jellyfin";
    };

  users.groups.media.members = [
    "jellyfin"
    "sonarr"
    "radarr"
    "lidarr"
    "bazarr"
    "transmission"
  ];

  users.groups.transmission.members = [
    "sonarr"
    "radarr"
    "lidarr"
    "bazarr"
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
        mountPoint = "/var/lib/private/jellyseerr"; # StateDirectory
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
        mountPoint = "/var/lib/private/prowlarr"; # StateDirectory
      };
    };
  };
}
