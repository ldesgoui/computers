_:
{
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
}
