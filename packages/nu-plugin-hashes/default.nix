{
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  nushell,
}:
let
in
rustPlatform.buildRustPackage {
  pname = "nushell_plugin_hashes";
  src = fetchFromGitHub {
    owner = "ArmoredPony";
    repo = "nu_plugin_hashes";
    rev = "e6e02b5c4e4f2a487fd1bbcad264b74c0e95917a";
    hash = "sha256-ssKntDcItvyZX/5DI6mn5+sRhyrRzRmO7tvEP+w8rSQ=";
  };
  cargoHash = "sha256-ikwWwLmQ3ZsNeOzuuHpjFdIB7DJ3sHUz2A5W/Uwl6yE=";

  version = "latest";
}
