_:
{
  systemd.tmpfiles.settings."20-media-server" =
    let
      z = mode: user: group: { z = { inherit mode user group; }; };
    in
    {
      "/srv/movies" = z "02775" "root" "media";
      "/srv/series" = z "02775" "root" "media";
      "/srv/music" = z "02775" "root" "media";
    };

  users.groups.media.members = [
    "jellyfin"
    "sonarr"
    "radarr"
    "lidarr"
    "bazarr"
  ];

  zfs.datasets.main._.enc._.media = {
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
}
