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

  cfg = config.nazarick.service.playerctl;
in
{
  options.nazarick.service.playerctl = {
    enable = mkEnableOption "playerctl";
  };

  config = mkIf cfg.enable {
    services.playerctld = {
      enable = true;
    };
    home.packages = [ pkgs.playerctl ];
  };
}
