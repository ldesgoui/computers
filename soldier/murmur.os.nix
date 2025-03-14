_:
{ config, ... }: {
  age.secrets.murmur_password = {
    rekeyFile = ./murmur_password.age;
  };

  security.acme.certs."cool-zone.lde.sg" = {
    extraDomainNames = [
      "soldier.wi.lde.sg"
      "mumble.ldesgoui.xyz"
    ];

    reloadServices = [ "murmur" ];
    group = "murmur";
  };

  services.murmur =
    let
      certDir = config.security.acme.certs."cool-zone.lde.sg".directory;
    in
    {
      enable = true;

      openFirewall = true;

      environmentFile = config.age.secrets.murmur_password.path;

      sslCert = "${certDir}/full.pem";
      sslKey = "${certDir}/key.pem";

      registerName = "da server >;D";

      bandwidth = 558000;
      imgMsgLength = 1024 * 1024 * 10;

      password = "$PASSWORD";

      welcometext = builtins.replaceStrings [ "\n" ] [ "<br />" ] ''
        Wow! It's you! Nice!
        The server has moved hosts :)
      '';

      extraConfig = ''
        rememberchannelduration=3600
      '';
    };

  systemd.services.murmur = {
    restartIfChanged = false;
  };
}
