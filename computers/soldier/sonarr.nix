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

  zfs.datasets.main._.enc._.services._.sonarr = {
    mountPoint = "/var/lib/sonarr"; # Weird hardcode
  };
}
