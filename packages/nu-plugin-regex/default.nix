{
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  nushell,
}:
let
in
rustPlatform.buildRustPackage {
  pname = "nushell_plugin_regex";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_regex";
    rev = "316e0a3aacd3fdbaaa055e7bdd7447365fabc636";
    hash = "sha256-Kub2OFMMb93+9PaK2tM5HDrB8vmSQVO/NjaBLpzlOt4=";
  };
  cargoHash = "sha256-gZQA4ozE52PBs/Dkqj2+FiwQIdT8dBrWNCju9DJ+Qw8=";

  version = "latest";
}
