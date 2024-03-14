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

  config = mkIf cfg.enable { programs.steam.enable = true; };
}
