{
  networking.resolvconf.useLocalResolver = false;

  services.kresd = {
    enable = true;
    listenPlain = [ "53" ];
  };
}
