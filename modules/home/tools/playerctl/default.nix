{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  user = config.nazarick.user;
  cfg = config.nazarick.tools.playerctl;
in
{
  options.nazarick.tools.playerctl = {
    enable = mkEnableOption "playerctl";
  };

  config = mkIf cfg.enable {
    services.playerctld = {
      enable = true;
    };
  };
}
