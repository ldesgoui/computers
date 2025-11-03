_:
{
  systemd.tmpfiles.settings."20-media-server" =
    let
      z = mode: user: group: { z = { inherit mode user group; }; };
    in
    {
      "/srv/home" = z "02775" "root" "media";
      "/srv/movies" = z "02775" "root" "media";
      "/srv/music" = z "02775" "root" "media";
      "/srv/series" = z "02775" "root" "media";
      "/srv/movies-fast" = z "02775" "root" "media";
      "/srv/series-fast" = z "02775" "root" "media";
    };

  users.groups.media.members = [
    "jellyfin"

    "sonarr"
    "radarr"
    "lidarr"
    "bazarr"

    "syncthing"
  ];

  zfs.datasets = {
    main.enc.media = {
      properties = {
        compression = "off";
        recordsize = "1M";
      };

      home = {
        mountPoint = "/srv/home";
      };

      movies = {
        mountPoint = "/srv/movies-fast";
      };

      series = {
        mountPoint = "/srv/series-fast";
      };
    };

    slow.enc.media = {
      properties = {
        compression = "off";
      };

      movies = {
        mountPoint = "/srv/movies";
      };

      music = {
        mountPoint = "/srv/music";
      };

      series = {
        mountPoint = "/srv/series";
      };
    };
  };
}
