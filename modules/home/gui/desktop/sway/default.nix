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
  cfg = config.nazarick.gui.desktop.sway;
  launcher = ''nu -c "tofi-drun | swaymsg exec -- ...(\\$in | str trim | split row ' ')"'';

  extraLines = builtins.readFile (
    pkgs.substitute {
      src = ./sway.conf;
      substitutions = [ ];
    }
  );

in
{
  options.nazarick.gui.desktop.sway = {
    enable = lib.mkEnableOption "sway";
  };

  config = lib.mkIf cfg.enable {

    wayland.windowManager.sway = {
      enable = true;
      package = null; # Let NixOS handle this one
      checkConfig = false; # Annoying with swayfx
      extraConfig = extraLines;
      systemd.enable = true;
      config = {
        menu = launcher;
        modifier = "Mod4"; # Right now only used for floating_modifier
        terminal = "kitty";
        keybindings = { }; # Remove default
        bars = [ ]; # Remove default
      };
    };

    xdg.configFile."sway/config.d/swayosd.conf" = {
      enable = true;
      source = ./config.d/swayosd.conf;
    };

  };
}
