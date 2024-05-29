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

  cfg = config.nazarick.apps.defaults;
in
{
  options.nazarick.apps.defaults = {
    enable = mkEnableOption "Defaults";
  };

  config = mkIf cfg.enable {

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "default-web-browser" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
        "x-scheme-handler/mw-matlab" = [ "mw-matlab.desktop" ];
        "x-scheme-handler/mw-simulink" = [ "mw-simulink.desktop" ];
        "x-scheme-handler/mw-matlabconnector" = [ "mw-matlabconnector.desktop" ];
        "application/pdf" = [ "okular.desktop" ];
        "video/*" = [ "mpv.desktop" ];
        "audio/*" = [ "mpv.desktop" ];
        "application/zip" = [ "ark.desktop" ];
        "application/gzip" = [ "ark.desktop" ];
        "application/x-tar" = [ "ark.desktop" ];
        "application/x-bzip" = [ "ark.desktop" ];
        "application/x-bzip2" = [ "ark.desktop" ];
        "application/x-7z-compressed" = [ "ark.desktop" ];
        "application/x-rar" = [ "ark.desktop" ];
        "application/xz" = [ "ark.desktop" ];
        # "application/x-desktop"
      };
    };
  };
}
