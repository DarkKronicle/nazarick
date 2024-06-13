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
    rev = "5873a8416d7933045d4ccd15c3f28a967150289c";
    hash = "sha256-8TTuYaPT17/b5d/7hwRbKWl9gFsaFagnFgWFpnm1hKU=";
  };

  cargoHash = "sha256-KDR6tkK1MXbURSW2ZwiuEYEIPDOZtIsaJjDPIt/Stcc=";

  version = "0.94.0";
}
