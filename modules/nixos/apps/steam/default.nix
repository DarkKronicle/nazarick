{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.nazarick;
let
  cfg = config.nazarick.apps.steam;
in
{
  options.nazarick.apps.steam = with types; {
    enable = mkBoolOpt false "Enable Steam";
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [ protonup ];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/darkkronicle/.steam/root/compatibilitytools.d";
    };
  };
}
