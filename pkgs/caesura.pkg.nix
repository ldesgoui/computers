_:
{ lib
, rustPlatform
, fetchFromGitHub
}:
let
  pname = "caesura";
  version = "0.25.0";
in
rustPlatform.buildRustPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "RogueOneEcho";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-dMXGIN/chAmq5UW5jgsfduRfxSE1ekn1O8vniAV/Z80=";
  };

  cargoHash = "sha256-Lv2bA06gCJC0ZsgbvSrhO84wWmUlMOaWDPwYscUbH2k=";

  doCheck = false;
}
