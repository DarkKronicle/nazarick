{
  mylib,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.nazarick.app.game;

in
{
  options.nazarick.app.game = {
    protonup.enable = mkEnableOption "protonup";
  };

  config = {

    home.packages = (lib.optionals cfg.protonup.enable [ pkgs.protonup-ng ]);

    home.sessionVariables = mkIf cfg.protonup.enable {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${config.home.username}/.steam/root/compatibilitytools.d";
    };
  };
}
