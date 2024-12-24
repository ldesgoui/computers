{
  networking.resolvconf.useLocalResolver = false;

  services.kresd = {
    enable = true;
    listenPlain = [
      "lo:53"
      "tailscale0:53"
      "wg0:53"
    ];
    extraConfig = ''
      cache.size = 100 * MB
    '';
  };
}
