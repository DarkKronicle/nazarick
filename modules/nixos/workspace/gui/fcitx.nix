{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nazarick.workspace.gui.fcitx;
in
{
  options.nazarick.workspace.gui.fcitx = {
    enable = mkEnableOption "fcitx5 for japanese input";
  };

  config = mkIf cfg.enable {
    i18n.inputMethod =
      if (config.system.nixos.release == "24.05") then
        {
          enabled = "fcitx5";
          fcitx5 = {
            plasma6Support = true;
            waylandFrontend = true;
            addons = with pkgs; [
              fcitx5-mozc
              fcitx5-gtk
            ];
          };
        }
      else
        {
          enable = true;
          type = "fcitx5";
          fcitx5 = {
            plasma6Support = true;
            waylandFrontend = true;
            addons = with pkgs; [
              fcitx5-mozc
              fcitx5-gtk
            ];
          };
        };
  };
}
