{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.tools.fcitx;

  catppuccin_theme = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "fcitx5";
    rev = "ce244cfdf43a648d984719fdfd1d60aab09f5c97";
    hash = "sha256-uFaCbyrEjv4oiKUzLVFzw+UY54/h7wh2cntqeyYwGps=";
  };
in
{
  options.nazarick.tools.fcitx = {
    enable = mkEnableOption "fcitx5";
  };

  config = mkIf cfg.enable {
    # TODO: Can probably make this use xdg.dataFile, but had issues with that
    home.file.".local/share/fcitx5/themes" = {
      source = "${catppuccin_theme}/src/";
      recursive = true;
    };
  };
}
