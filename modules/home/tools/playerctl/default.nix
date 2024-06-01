{
  lib,
  mylib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

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
