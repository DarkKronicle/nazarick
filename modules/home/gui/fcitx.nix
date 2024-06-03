{
  lib,
  mylib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.gui.fcitx;

  catppuccin_theme = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "fcitx5";
    rev = "ce244cfdf43a648d984719fdfd1d60aab09f5c97";
    hash = "sha256-uFaCbyrEjv4oiKUzLVFzw+UY54/h7wh2cntqeyYwGps=";
  };
in
{
  options.nazarick.gui.fcitx = {
    enable = mkEnableOption "fcitx5";
  };

  config = mkIf cfg.enable {
    xdg.dataFile."fcitx5/themes" = {
      enable = true;
      source = "${catppuccin_theme}/src/";
      recursive = true;
    };
  };
}
