{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.nazarick.tools.kdeconnect;
in
{
  options.nazarick.tools.kdeconnect = {
    enable = mkEnableOption "KDE-Connect";
  };

  config = mkIf cfg.enable { home.packages = [ pkgs.kdePackages.kdeconnect-kde ]; };
}
