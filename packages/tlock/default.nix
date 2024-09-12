{
  fetchFromGitHub,
  buildGoModule,
}:
let
  version = "1.2.0";
in
buildGoModule {
  inherit version;
  pname = "tlock";

  vendorHash = "sha256-gy2aPcOrhN1M27qYiqRvNjy987Oh7/MHMvbRLEpV3Iw=";

  # Requires wifi
  doCheck = false;

  src = fetchFromGitHub {
    owner = "drand";
    repo = "tlock";
    rev = "v${version}";
    hash = "sha256-3qO5xGcKj7m033B/lWoeewUf9XbiY+GrQFBBuymOXzo=";
  };

}
