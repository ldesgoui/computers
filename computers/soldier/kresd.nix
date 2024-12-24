{
  networking.resolvconf.useLocalResolver = false;

  services.kresd = {
    enable = true;
    listenPlain = [ "53" ];
    extraConfig = ''
      cache.size = 100 * MB
    '';
  };
}
