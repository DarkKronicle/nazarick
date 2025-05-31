{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.workspace.gui.common;
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.workspace.gui.common = {
    enable = lib.mkEnableOption "Common GUI configuration";
  };

  config = lib.mkIf cfg.enable {

    nazarick.workspace.gui = {
      sddm.enable = lib.mkOverride 500 true;
      fonts.enable = lib.mkOverride 500 true;
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gnome
      ];
      configPackages = with pkgs; [ gnome-keyring ];
      config = {
        common = {
          default = [
            "gtk"
            "wlr"
            "kde"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
          "org.freedesktop.portal.FileChooser" = [ "kde" ];
        };
      };
    };

  };
}
