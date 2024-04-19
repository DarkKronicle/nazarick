{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.nazarick.sddm;
in
{
  options.nazarick.sddm = {
    enable = mkEnableOption "sddm theming";
  };

  config = mkIf cfg.enable {
    services.displayManager.sddm = {
      theme = "where_is_my_sddm_theme"; # or _qt5
    };

    environment.systemPackages = with pkgs; [
      (where-is-my-sddm-theme.override {
        themeConfig = {
          General = {
            passwordCharacter = "*";
            passwordMask = true;
            passwordInputWidth = 0.5;
            passwordInputCursorVisible = true;
            showUsersByDefault = false;
            showSessionsByDefault = true;
            backgroundFill = "#000000";
          };
        };
      })
    ];
  };
}
