{
  mylib,
  config,
  lib,
  pkgs,
  system,
  inputs,
  ...
}:
let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.game;

in
{
  imports = mylib.scanPaths ./.;

  options.nazarick.app.game = {
    protonup.enable = mkEnableOption "protonup";
    mint.enable = mkEnableOption "mint mod manager";
  };

  config = {

    home.packages =
      (lib.optionals cfg.protonup.enable [ pkgs.protonup-ng ])
      ++ (lib.optionals cfg.mint.enable [ inputs.mint.packages.${system}.mint ]);

    home.sessionVariables = mkIf cfg.protonup.enable {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${config.home.username}/.steam/root/compatibilitytools.d";
    };
  };
}
