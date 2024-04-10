{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.apps.thunderbird;
in
{
  options.nazarick.apps.thunderbird = {
    enable = mkEnableOption "Thunderbird";
  };

  config = mkIf cfg.enable {

    programs.thunderbird = {
      enable = true;
      package = pkgs.betterbird;
      profiles = {
        "main" = {
          isDefault = true;
        };
      };
    };
  };
}
