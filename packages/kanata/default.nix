{
  stdenv,
  lib,
  darwin,
  rustPlatform,
  fetchFromGitHub,
  withCmd ? true,
}:

rustPlatform.buildRustPackage rec {
  pname = "kanata";
  version = "latest";

  src = fetchFromGitHub {
    owner = "jtroo";
    repo = pname;
    rev = "60ce29a23c217fb31729945f850b505a7a9e0273";
    hash = "sha256-DienE4An34F+/tR5LxP346ACU5GsP3PSOvl0w6o450Q=";
  };

  cargoHash = "sha256-p06ya6RjEwoZdTPtbe1JZFd4O92rrysyvnU87uA4+yU=";

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.IOKit ];

  buildFeatures = lib.optional withCmd "cmd";

  postInstall = ''
    install -Dm 444 assets/kanata-icon.svg $out/share/icons/hicolor/scalable/apps/kanata.svg
  '';

  meta = with lib; {
    description = "Tool to improve keyboard comfort and usability with advanced customization";
    homepage = "https://github.com/jtroo/kanata";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [
      bmanuel
      linj
    ];
    platforms = platforms.unix;
    mainProgram = "kanata";
    broken = stdenv.isDarwin;
  };
}
