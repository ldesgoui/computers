_:
{ config, ... }: {
  services.jellyseerr = {
    enable = true;
  };

  services.kanidm.provision.systems.oauth2.jellyseerr = {
    originUrl = "https://js.ldesgoui.xyz";
    originLanding = "https://js.ldesgoui.xyz";
    displayName = "Jellyseerr";
    preferShortUsername = true;
    scopeMaps.media_viewers = [ "openid" "profile" ];
  };

  services.nginx.virtualHosts = {
    # "jellyseerr.int.lde.sg" = {
    "js.ldesgoui.xyz" = {
      listen = [
        { addr = "0.0.0.0"; }
        { addr = "[::0]"; }
        { addr = "[fd4c:a29e:23d9::1]"; port = 9080; ssl = false; proxyProtocol = true; }
        { addr = "[fd4c:a29e:23d9::1]"; port = 9443; ssl = true; proxyProtocol = true; }
      ];
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;
      locations."/".proxyPass = "http://[::1]:${toString config.services.jellyseerr.port}";
    };

    # "js.ldesgoui.xyz" = {
    #   enableACME = true;
    #   acmeRoot = null;
    #   globalRedirect = "jellyfin.int.lde.sg";
    # };
  };

  zfs.datasets.main.enc.services.jellyseerr = {
    mountPoint = "/var/lib/private/jellyseerr"; # StateDirectory
  };
}
