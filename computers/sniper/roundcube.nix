{ config, pkgs, ... }: {
  services.roundcube = {
    enable = true;
    hostName = "mx.ldesgoui.xyz";
    extraConfig = ''
      $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };

  services.postgresql = {
    package = pkgs.postgresql_15;
  };
}
