{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.nazarick.desktop.plasma;
in
{
  options.nazarick.desktop.plasma = {
    enable = mkEnableOption "Enable plasma";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
