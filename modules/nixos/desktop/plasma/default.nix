{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
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
