{ pkgs-unstable, ... }:
final: prev: {
  fluent-icon-theme = pkgs-unstable.fluent-icon-theme.overrideAttrs (_: {
    version = "master";
    src = pkgs-unstable.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Fluent-icon-theme";
      rev = "7d20e2d2a2876dc859ec166bde7508cd367186b4";
      hash = "sha256-gLEKdg0k9WMm9UUDE/q9cGk1sR3BT2/P6MikgONUxss=";
    };
  });
}
