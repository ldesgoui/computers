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

  # TODO: replace with something safer
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
