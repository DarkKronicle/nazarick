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
    rev = "16f9027056453bed09fb951c0b213dcd5e7187b2";
    hash = "sha256-mqy11yA/qfBXVq/sujLyChzmckI5LCbG5Q9cP7bWZbo=";
  };

  cargoHash = "sha256-+4wzqAiZ7xrBHncErtsRi8FPLMdKmW6bxtn7T78XINU=";

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
