{ config, pkgs, ... }:
let
  web-config = pkgs.runCommand "jellyfin-web-config-override"
    {
      nativeBuildInputs = [ pkgs.jq ];
    }
    ''
      mkdir $out/web
      jq '.menuLinks = [
        { name: "Request movies and shows", url: "https://js.ldesgoui.xyz" }
      ]' ${pkgs.jellyfin-web}/share/jellyfin-web/config.json > $out/web/config.json
    '';
in
{
  services.jellyfin = {
    enable = true;
  };

  services.kanidm.provision.systems.oauth2.jellyfin = {
    originUrl = "https://jf.ldesgoui.xyz/sso/OID/redirect/kanidm";
    originLanding = "https://jf.ldesgoui.xyz";
    displayName = "Jellyfin";
    preferShortUsername = true;
    scopeMaps = {
      media_admins = [ "openid" "profile" "groups" ];
      media_viewers = [ "openid" "profile" "groups" ];
      media_listeners = [ "openid" "profile" "groups" ];
    };
  };

  services.nginx.virtualHosts = {
    # "jellyfin.int.lde.sg" = {
    "jf.ldesgoui.xyz" = {
      listenAddresses = [ "0.0.0.0" "[::0]" ];
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

      locations."= /web/config.json" = {
        root = web-config;
      };
    };

    # "jf.ldesgoui.xyz" = {
    #   enableACME = true;
    #   acmeRoot = null;
    #   globalRedirect = "jellyfin.int.lde.sg";
    # };
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
