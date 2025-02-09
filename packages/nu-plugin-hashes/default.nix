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
    rev = "fd62cdcf5be1a4b07c74d59e975cb9d1db896c83";
    hash = "sha256-9ihEC2R3/ooarRbLHVuCl0WD7CFF7fGkU5ZBW29mNd0=";
  };
  cargoHash = "sha256-wZwzntWaJzuZmJcK0Sxhz/U8Oziv/y/zhD+iuhcLvMk=";

  version = "latest";
}
