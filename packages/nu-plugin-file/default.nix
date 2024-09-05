{
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  nushell,
}:
let
in
rustPlatform.buildRustPackage {
  pname = "nushell_plugin_file";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_file";
    rev = "4c79e53daa22fb9af297a9196775a82e9728b3dc";
    hash = "sha256-+DlA4xZGLXEO/bGH3EfCcaJ5+7dbv3hyY5LjpsxEvlw=";
  };
  cargoHash = "sha256-ku9LmeJHvHj2WZBNpDBviSKSSYAAAAAX0vdronjrHl4=";

  version = "latest";
}
