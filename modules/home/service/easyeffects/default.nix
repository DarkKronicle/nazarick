{
  lib,
  config,
  mylib,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.service.easyeffects;
in
{
  options.nazarick.service.easyeffects = {
    enable = mkEnableOption "EasyEffects";
  };

  config = mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
    };
    systemd.user.services.easyeffects = {
      Service = {
        # This service hangs on system shutdown fairly frequently
        TimeoutSec = "10";
      };
    };
  };
}
