{ config, lib, ... }:
let
  cfg = config.services.nginx.reversePreTls;
in
{
  options = {
    services.nginx.reversePreTls = {
      enable = lib.mkEnableOption "Reverse-proxy without TLS termination";

      names = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = { };
      };
    };
  };

  config.services.nginx = lib.mkIf cfg.enable {
    defaultSSLListenPort = lib.mkDefault 20443;

    streamConfig = ''
      map $ssl_preread_server_name $target {
        ${lib.concatLines (lib.mapAttrsToList (n: v: "${n} ${v};") cfg.names)}
        default [::1]:${toString config.services.nginx.defaultSSLListenPort};
      }

      server {
        listen 0.0.0.0:443;
        listen [::0]:443;
        ssl_preread on;
        proxy_pass $target;
      }
    '';

    virtualHosts = lib.mapAttrs (_: _: { locations."/".return = "301 https://$host$request_uri"; }) cfg.names;
  };
}
