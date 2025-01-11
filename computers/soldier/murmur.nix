{ config, ... }: {
  age.secrets.murmur_password = {
    rekeyFile = ./murmur_password.age;
  };

  security.acme.certs."mumble.ldesgoui.xyz" = {
    # extraDomainNames = [ "cool-zone.lde.sg" ];

    reloadServices = [ "murmur" ];
    group = "murmur";
  };

  services.murmur =
    let
      certDir = config.security.acme.certs."mumble.ldesgoui.xyz".directory;
    in
    {
      enable = true;

      openFirewall = true;

      sslCert = "${certDir}/full.pem";
      sslKey = "${certDir}/key.pem";

      registerName = "SORRY IF I BROKE SOMETHING";

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
}
