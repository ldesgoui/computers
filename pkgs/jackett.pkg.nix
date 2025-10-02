_:
{ lib
, stdenv
, buildDotnetModule
, fetchFromGitHub
, dotnetCorePackages
, openssl
, mono
, nixosTests
,
}:

buildDotnetModule rec {
  pname = "jackett";
  version = "0.24.24";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha512-pe/vOff1MU5PxjJMip/rNH8L7JZfdSpFAHN6l3yeIstBbjpLWsmMXCawH8Ih33ITpuxFuVsVYTv5+sUS1qvrsA==";
  };

  projectFile = "src/Jackett.Server/Jackett.Server.csproj";
  nugetDeps = ./jackett-deps.json;

  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;

  dotnetInstallFlags = [
    "--framework"
    "net9.0"
  ];

  patches = [ ./jackett-aither-api.patch ];
  postPatch = ''
    substituteInPlace ${projectFile} ${testProjectFile} \
      --replace-fail '<TargetFrameworks>net9.0;net471</' '<TargetFrameworks>net9.0</'
  '';

  runtimeDeps = [ openssl ];

  # doCheck = !(stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64); # mono is not available on aarch64-darwin
  doCheck = false;
  nativeCheckInputs = [ mono ];
  testProjectFile = "src/Jackett.Test/Jackett.Test.csproj";

  postFixup = ''
    # For compatibility
    ln -s $out/bin/jackett $out/bin/Jackett || :
    ln -s $out/bin/Jackett $out/bin/jackett || :
  '';
  passthru.updateScript = ./updater.sh;

  passthru.tests = { inherit (nixosTests) jackett; };

  meta = with lib; {
    description = "API Support for your favorite torrent trackers";
    mainProgram = "jackett";
    homepage = "https://github.com/Jackett/Jackett/";
    changelog = "https://github.com/Jackett/Jackett/releases/tag/v${version}";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [
      edwtjo
      nyanloutre
      purcell
    ];
  };
}
