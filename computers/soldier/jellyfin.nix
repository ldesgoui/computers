{ config, ... }: {
  services.jellyfin = {
    enable = true;
  };

  services.kanidm.provision.systems.oauth2.jellyfin = {
    originUrl = "https://jf.ldesgoui.xyz/sso/OID/redirect/kanidm";
    originLanding = "https://jf.ldesgoui.xyz";
    displayName = "Jellyfin";
    preferShortUsername = true;
    scopeMaps = {
      media_viewers = [ "openid" "profile" ];
      media_listeners = [ "openid" "profile" ];
    };
    claimMaps.roles.valuesByGroup = {
      media_viewers = [ "media_viewers" ];
      media_listeners = [ "media_listeners" ];
    };
  };

  services.nginx.virtualHosts = {
    "jellyfin.int.lde.sg" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://[::1]:8096";
        extraConfig = "proxy_buffering off;";
      };

      locations."/socket" = {
        proxyPass = "http://[::1]:8096";
        proxyWebsockets = true;
      };
    };

    "jf.ldesgoui.xyz" = {
      enableACME = true;
      acmeRoot = null;
      globalRedirect = "jellyfin.int.lde.sg";
    };
  };

  systemd.tmpfiles.settings."20-jellyfin" =
    let
      z = mode: user: group: { z = { inherit mode user group; }; };
    in
    {
      ${config.services.jellyfin.dataDir} = z "0755" "jellyfin" "jellyfin";
      ${config.services.jellyfin.cacheDir} = z "0755" "jellyfin" "jellyfin";
    };

  zfs.datasets.main._.enc._.services._.jellyfin = {
    _.data = {
      mountPoint = config.services.jellyfin.dataDir;
    };

    _.cache = {
      mountPoint = config.services.jellyfin.cacheDir;
    };
  };
}
