# This handles sway config, but NixOS sway module handles installing sway.
{
  config,
  lib,
  pkgs,
  mypkgs,
  options,
  ...
}:
let
  cfg = config.nazarick.gui.desktop.niri;
  launcher = ''nu -c "tofi-drun | swaymsg exec -- ...(\\$in | str trim | split row ' ')"'';
in
{
  options.nazarick.gui.desktop.niri = {
    enable = lib.mkEnableOption "sway";
  };

  config = lib.mkIf cfg.enable {

    xdg.configFile."niri/config.kdl" = {
      enable = true;
      source = ./config.kdl;
    };

  };
}
