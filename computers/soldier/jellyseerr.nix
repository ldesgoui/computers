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
    "jellyseerr.int.lde.sg" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;
      locations."/".proxyPass = "http://[::1]:${toString config.services.jellyseerr.port}";
    };

    "js.ldesgoui.xyz" = {
      enableACME = true;
      acmeRoot = null;
      globalRedirect = "jellyfin.int.lde.sg";
    };
  };

  zfs.datasets.main._.enc._.services._.jellyseerr = {
    mountPoint = "/var/lib/private/jellyseerr"; # StateDirectory
  };
}