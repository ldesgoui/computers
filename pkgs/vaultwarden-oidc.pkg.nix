_:
{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
  # , libiconv
  # , Security
  # , CoreServices
  # , SystemConfiguration
, dbBackend ? "sqlite"
, libmysqlclient
, postgresql
,
}:

rustPlatform.buildRustPackage rec {
  pname = "vaultwarden";
  version = "1.32.7-1";

  src = fetchFromGitHub {
    owner = "Timshel";
    repo = "vaultwarden";
    rev = "1.32.7-1";
    hash = "sha256-gXREqjAycrViVfqGQCcUb8upCXunwLG+Tyg3YCPROMs=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-9lihL9QqlmTBbtyccheaolc9dMOmDeMEvUXqrGdrD7k=";

  # used for "Server Installed" version in admin panel
  env.VW_VERSION = version;

  nativeBuildInputs = [ pkg-config ];
  buildInputs =
    [ openssl ]
    # ++ lib.optionals stdenv.hostPlatform.isDarwin [
    #   libiconv
    #   Security
    #   CoreServices
    #   SystemConfiguration
    # ]
    ++ lib.optional (dbBackend == "mysql") libmysqlclient
    ++ lib.optional (dbBackend == "postgresql") postgresql;

  buildFeatures = dbBackend;

  meta = with lib; {
    license = licenses.agpl3Only;
    mainProgram = "vaultwarden";
  };
}
