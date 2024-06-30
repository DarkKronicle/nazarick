{
  lib,
  mylib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.nheko;
in
{
  options.nazarick.app.nheko = {
    enable = mkEnableOption "nheko";
  };

  config = mkIf cfg.enable { home.packages = [ pkgs.nheko ]; };
}
