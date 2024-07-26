{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.nazarick.gui.ags;
in
{
  imports = [ inputs.ags.homeManagerModules.default ];

  options.nazarick.gui.ags = {
    enable = lib.mkEnableOption "ags";
  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [ sass ];

    programs.ags = {
      enable = true;
      extraPackages = with pkgs; [
        upower
        gnome.gnome-bluetooth
        gvfs
        libdbusmenu-gtk3
        sass
      ];
    };
  };
}
