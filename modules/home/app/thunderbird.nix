{
  lib,
  config,
  pkgs,
  mylib,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.thunderbird;
in
{
  options.nazarick.app.thunderbird = {
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
