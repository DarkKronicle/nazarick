{
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  nushell,
}:
let
in
rustPlatform.buildRustPackage {
  pname = "nushell_plugin_explore";
  src = fetchFromGitHub {
    owner = "amtoine";
    repo = "nu_plugin_explore";
    rev = "8195d8dcaa4b0c444203fcbb9148e65afa6a4a1d";
    hash = "sha256-r/XJow2Degh4CsPBfMbriip3eVaJchLpPvFVO2kTVXA=";
  };
  cargoHash = "sha256-ku9LmeJHvHj2WZBNpDBviSKSSYRlgbfX0vdronjrHl4=";

  version = "0.96.0";
}
