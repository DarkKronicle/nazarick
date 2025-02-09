{
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  fontconfig,
}:
let
in
rustPlatform.buildRustPackage {
  pname = "nushell_plugin_plotters";
  src = fetchFromGitHub {
    owner = "cptpiepmatz";
    repo = "nu-jupyter-kernel";
    rev = "70512622928bc4ee931dc42646fe226558392003";
    hash = "sha256-jU3/aC+tItEoa2lA6wqg5WK2YNC1JdzBREgOFlageIs=";
  };

  cargoHash = "sha256-fdAV1Vw5ShyLfuk2tFT/WrYyu6Yghvpaxgz40br//l8=";

  buildAndTestSubdir = "crates/nu_plugin_plotters";

  version = "latest";

  nativeBuildInputs = [
    pkg-config
    openssl
    fontconfig
  ];

  buildInputs = [
    openssl
    fontconfig
  ];

}
