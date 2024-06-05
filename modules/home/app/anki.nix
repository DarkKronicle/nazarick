{
  lib,
  mylib,
  config,
  pkgs,
  mypkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.anki;
in
{
  options.nazarick.app.anki = {
    enable = mkEnableOption "anki";
    other-pkgs = mkEnableOption "Install other packages to pair with anki";
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals cfg.other-pkgs ([
      pkgs.mecab
      mypkgs.kamite-bin
    ]);

    xdg.desktopEntries."anki" = {
      name = "Anki";
      comment = "An intelligent spaced-repetition memory training program";
      genericName = "Flashcards";
      type = "Application";
      mimeType = [
        "application/x-apkg"
        "application/x-anki"
        "application/x-ankiaddon"
      ];
      icon = "anki";
      exec = "env QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor ${pkgs.anki}/bin/anki";
      settings = {
        SingleMainWindow = "true";
      };
      categories = [
        "Education"
        "Languages"
      ];
    };
  };
}
