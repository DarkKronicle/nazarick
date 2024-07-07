# This handles sway config, but NixOS sway module handles installing sway. 
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.gui.sway;

in
{

  options.nazarick.gui.sway = {
    enable = lib.mkEnableOption "sway";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;
      package = null; # Let NixOS handle this one

    };
  };

}
