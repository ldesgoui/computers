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
    };

  users.groups.media.members = [
    "jellyfin"

    "sonarr"
    "radarr"
    "lidarr"
    "bazarr"

    "syncthing"
  ];

  zfs.datasets.main._.enc._.media = {
    _.home = {
      mountPoint = "/srv/home";
    };

    _.movies = {
      mountPoint = "/srv/movies";
    };

    _.music = {
      mountPoint = "/srv/music";
    };

    _.series = {
      mountPoint = "/srv/series";
    };
  };
}
