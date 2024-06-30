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
    rev = "9be16d9ead3699932376d8e2a54b96145b9af19d";
    hash = "sha256-SeuplqaLn+ysRfDTm0yBtzpSaXqV9eFpRBB22dHg1WU=";
  };
  cargoHash = "sha256-HsjeveIcu7kt2HLThsi4V/gN4CcK+qrbzl0XN1goboI=";

  version = "0.95.0";
}
