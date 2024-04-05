{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nazarick.tools.fcitx;
in
{
  options.nazarick.tools.fcitx = {
    enable = mkEnableOption "fcitx5 for japanese input";
  };

  config = mkIf cfg.enable {
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5 = {
        plasma6Support = true;
        waylandFrontend = true;
        addons = with pkgs; [ fcitx5-mozc ];
      };
    };
  };
}
