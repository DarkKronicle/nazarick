{
  lib,
  pkgs,
  mypkgs,
  config,
  mylib,
  ...
}:
let
  cfg = config.nazarick.gui.desktop;

  launcher = ''nu -c "tofi-drun | swaymsg exec -- ...(\\$in | str trim | split row ' ')"'';

  wallpaperPath = "${mypkgs.system-wallpapers}/share/wallpapers/system-wallpapers";
  schoolWallpaperPath = "${
    mypkgs.system-wallpapers.override {
      name = "school-wallpapers";
      filterFunc = (wall: !(builtins.elem "weaboo" (wall.tags or [ ])));
    }
  }/share/wallpapers/school-wallpapers";
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.gui.desktop = {
    enable = lib.mkEnableOption "Base desktop environment (no window manager)";
  };

  config = lib.mkIf cfg.enable {

    nazarick.gui = {
      gammastep.enable = true;
      swww = {
        enable = true;
        wallpaperPath = wallpaperPath;
        schoolWallpaperPath = schoolWallpaperPath;
      };
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

    home.packages =
      (with pkgs; [
        kdePackages.qqc2-desktop-style # https://discuss.kde.org/t/broken-kde-connect-theme/18451/5
        kdePackages.plasma-integration
        kdePackages.gwenview
        kdePackages.dolphin
        lxqt.pavucontrol-qt
        swayosd # Graphical volume controls # TODO: seems not QT rn?
        blueman
        nwg-displays # ~/.config/sway/outputs
        swayidle
        kdePackages.xwaylandvideobridge

        # Screenies
        grim
        slurp
      ])
      ++ [
        mypkgs.inhibit-bridge
      ];

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings =
        let
          highlight = "9d0df0";
          highlight2 = "ffffff";
          background = "000000";
        in
        {
          color = background;
          inside-color = background;
          inside-wrong-color = background;
          inside-clear-color = background;
          inside-ver-color = background;
          key-hl-color = background;

          ring-color = highlight;
          ring-clear-color = highlight2;
          ring-ver-color = highlight2;
          ring-wrong-color = highlight2;

          text-color = "ffffff";

          line-color = background;
          line-clear-color = background;
          line-wrong-color = background;
          line-ver-color = background;

          fade-in = 0.2;
          indicator = true;
          text-clear = "clear";
          text-wrong = "incorrect";
          text-ver = "checking...";
          font = "Recursive Mono Linear Static";
          daemonize = true;
        };
    };

    services.kdeconnect = {
      enable = true;
      indicator = true;
      package = pkgs.kdePackages.kdeconnect-kde;
    };
  };
}
