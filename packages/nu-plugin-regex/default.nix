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
    rev = "ff5ae1081ee602af8e83fe8560e9aecf2fcdeffc";
    hash = "sha256-HhUuBLLYwPkIktDaFEm02NOvf1QiPuNCvVk49FMo/jU=";
  };
  cargoHash = "sha256-n9FnYofUvZSpLin9CJRBgN0oVPQgepE807WtdHIPHRQ=";

  version = "latest";
}
