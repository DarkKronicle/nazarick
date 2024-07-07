# This handles sway config, but NixOS sway module handles installing sway. 
{
  config,
  lib,
  pkgs,
  mypkgs,
  ...
}:
let
  cfg = config.nazarick.gui.sway;
  launcher = ''nu -c "tofi-drun | swaymsg exec -- ...(\\$in | str trim | split row ' ')"'';

  extraLines = builtins.readFile (
    pkgs.substitute {
      src = ./sway.conf;
      substitutions = [
        "--replace-fail"
        "##LAUNCHER##"
        launcher
      ];
    }
  );
in
{

  options.nazarick.gui.sway = {
    enable = lib.mkEnableOption "sway";
  };

  config = lib.mkIf cfg.enable {

    # services.gnome-keyring.enable = true;

    wayland.windowManager.sway = {
      enable = true;
      package = null; # Let NixOS handle this one
      extraConfig = extraLines;
      systemd.enable = true;
      config = {
        menu = launcher;
        terminal = "kitty";
      };
    };

    home.packages = with pkgs; [ kdePackages.dolphin ];
  };

}
