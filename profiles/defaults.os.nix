{ self, ... }:
{ config, ... }: {
  age.secrets.root-password = {
    rekeyFile = "${self}/${config.networking.hostName}/root-password.age";
    generator.script = _: "mkpasswd -m sha-512";
  };


  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  security.sudo = {
    execWheelOnly = true;
    extraConfig = ''
      Defaults lecture = never
    '';
  };

  time.timeZone = "Europe/Paris";

  users = {
    mutableUsers = false;
    users.root = {
      hashedPasswordFile = config.age.secrets.root-password.path;
    };
  };
}
