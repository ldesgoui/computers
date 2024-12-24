{
  services.kresd = {
    enable = true;
    instances = 2;
    listenPlain = [ "0.0.0.0:53" "[::]:53" ];
    extraConfig = ''
      cache.size = 100 * MB

      modules = {
        predict = {
          window = 60,
          period = 24
        }
      }      
    '';
  };
}
