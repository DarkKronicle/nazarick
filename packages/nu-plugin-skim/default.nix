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
    rev = "v0.5.0";
    hash = "sha256-ohukYXmXL2HQol+tOjlwGSD5CKEloaj463BGBdvTElI=";
  };
  cargoHash = "sha256-1bswk6uPCz5azBncMyi4fcMfvxsAk+qD3Brv6gWv/eg=";
}
