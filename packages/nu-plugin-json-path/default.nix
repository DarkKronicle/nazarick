{
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  nushell,
}:
let
in
rustPlatform.buildRustPackage {
  pname = "nushell_plugin_json_path";
  src = fetchFromGitHub {
    owner = "fdncred";
    repo = "nu_plugin_json_path";
    rev = "1d2041570cd21a36a49b233d120da13f21f2b63f";
    hash = "sha256-xMi4e9fNFtzT7ZPrwC3Myrr2ClTnbs5aCkiDa5Me9F8=";
  };

  cargoHash = "sha256-mElcg7NuPUV4c0GGSLImdrNyAhBulx76GA5FYH5xNCU=";

  version = "latest";
}
