{ rustPlatform, fetchFromGitHub }:
let
  version = "0.4.1";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "nushell_plugin_skim";

  # cargoBuildFlags = [];

  # freshfetch depends on rust nightly features
  RUSTC_BOOTSTRAP = 1;

  src = fetchFromGitHub {
    owner = "idanarye";
    repo = "nu_plugin_skim";
    rev = "v0.4.1";
    hash = "sha256-H6VudFya3PXfw7N4rZIuwwcyuAY8esZCCFR/0Hl5oAA=";
  };
  cargoHash = "sha256-kpxE321TaubhI7aJcQtcEv9tdWXpJHEMqYODo0adG6I=";
}
