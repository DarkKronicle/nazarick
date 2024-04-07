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

  cfg = config.nazarick.apps.mpv;
in
{
  options.nazarick.apps.mpv = {
    enable = mkEnableOption "mpv";
  };

  config = mkIf cfg.enable {

    programs.mpv = {
      enable = true;
      package = pkgs.wrapMpv (pkgs.mpv-unwrapped.override { ffmpeg = pkgs.ffmpeg-full; }) {
        youtubeSupport = true;
        scripts = [ pkgs.mpvScripts.mpris ];
      };
    };
  };
}
