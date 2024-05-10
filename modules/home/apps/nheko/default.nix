{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.apps.nheko;
in
{
  options.nazarick.apps.nheko = {
    enable = mkEnableOption "nheko";
  };

  config = mkIf cfg.enable { home.packages = [ (pkgs.callPackage ./nheko.nix { }) ]; };
}
