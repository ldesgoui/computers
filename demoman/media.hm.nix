_:
{ pkgs, ... }: {
  home.packages = (builtins.attrValues {
    inherit (pkgs)
      ffmpeg
      yt-dlp

      chatterino2
      streamlink
      ;
  });
}
