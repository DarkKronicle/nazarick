{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.system.tablet;
in
{
  options.nazarick.system.tablet = {
    enable = lib.mkEnableOption "tablet";
  };

  config = lib.mkIf cfg.enable {
    hardware.opentabletdriver = {
      enable = true;
    };
  };

}
