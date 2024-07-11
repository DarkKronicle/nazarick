{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.nazarick.workspace.gui.sddm;
in
{
  options.nazarick.workspace.gui.sddm = {
    enable = mkEnableOption "sddm theming";
    kwin = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use kwin as the compositor";
    };
    defaultSession = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "sddm default session";
    };
  };

  config = mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      theme = "where_is_my_sddm_theme"; # or _qt5
      wayland = {
        enable = true;
        compositor = lib.mkDefault (if cfg.kwin then "kwin" else "weston");
      };
      package = lib.mkDefault pkgs.kdePackages.sddm; # Force qt6
      extraPackages =
        with pkgs.kdePackages;
        [
          qtvirtualkeyboard
          qtsvg
        ]
        ++ lib.optionals cfg.kwin [ pkgs.kdePackages.kwin ];
    };
    services.displayManager.defaultSession = cfg.defaultSession;
    qt.enable = true;

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
