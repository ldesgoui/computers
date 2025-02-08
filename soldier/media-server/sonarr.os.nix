_:
{
  services.sonarr = {
    enable = true;
  };

  # FIXME: ^ sonarr causing a build error because of its deps
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-6.0.36"
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];

  services.nginx.virtualHosts."sonarr.int.lde.sg" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:8989";
  };

  zfs.datasets.main.enc.services.sonarr = {
    mountPoint = "/var/lib/sonarr"; # Weird hardcode
  };
}
