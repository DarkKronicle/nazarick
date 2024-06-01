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

  cfg = config.nazarick.apps.nheko;
in
{
  options.nazarick.apps.nheko = {
    enable = mkEnableOption "nheko";
  };

  config = mkIf cfg.enable { home.packages = [ (pkgs.qt6.callPackage ./nheko-unwrapped.nix { }) ]; };
}
