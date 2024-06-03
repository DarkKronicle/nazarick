{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.nazarick.service.kdeconnect;
in
{
  options.nazarick.service.kdeconnect = {
    enable = mkEnableOption "KDE-Connect";
  };

  config = mkIf cfg.enable { home.packages = [ pkgs.kdePackages.kdeconnect-kde ]; };
}
