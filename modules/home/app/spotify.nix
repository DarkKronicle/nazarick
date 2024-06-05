{
  lib,
  config,
  pkgs,
  inputs,
  mylib,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.spotify;
in
{
  options.nazarick.app.spotify = {
    spotify-qt.enable = mkEnableOption "spotify-qt";
  };

  config = mkIf cfg.spotify-qt.enable { home.packages = with pkgs; [ spotify-qt ]; };
}
