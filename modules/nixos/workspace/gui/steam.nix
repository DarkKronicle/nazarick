{
  options,
  config,
  lib,
  mylib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.workspace.gui.steam;
  username = config.nazarick.workspace.user.name;
in
{
  options.nazarick.workspace.gui.steam = {
    enable = mkBoolOpt false "Enable Steam";
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [ protonup ];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
    };
  };
}
