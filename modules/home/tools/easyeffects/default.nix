{ lib, config, pkgs, ... }:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.tools.easyeffects;
in
{
  options.nazarick.tools.easyeffects = {
    enable = mkEnableOption "EasyEffects";
  };

  config = mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
    };
  };
}
