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
      "/srv/torrents" = z "02775" "root" "media";
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
      home = {
        mountPoint = "/srv/home";
      };
    };

    sata1.enc.media = {
      movies = {
        mountPoint = "/srv/movies";
      };
    };

    sata2.enc.media = {
      music = {
        mountPoint = "/srv/music";
      };

      series = {
        mountPoint = "/srv/series";
      };

      torrents = {
        mountPoint = "/srv/torrents";
      };
    };
  };
}
