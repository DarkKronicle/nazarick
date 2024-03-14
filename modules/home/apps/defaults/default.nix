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
      };
    };
  };
}
