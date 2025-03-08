{
  fetchFromGitHub,
  buildGoModule,
}:
let
  version = "1.2.0";
in
buildGoModule {
  inherit version;
  pname = "shamir";

  vendorHash = "sha256-uza1fWAdbxLBXNnORN0TneN48KSVXt57GE3EAGm/HI0=";

  src = fetchFromGitHub {
    owner = "dennis-tra";
    repo = "shamir";
    rev = "59855c362b475c0d14d7ef4c5f82edc64d4afe1b";
    hash = "sha256-OZnm5dwMg4hd7TtbnxE9bsG6e8DpoaSDF4B+w5RlDcw=";
  };

}
