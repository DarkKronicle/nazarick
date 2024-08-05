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
  cfg = config.nazarick.gui.sway;
  launcher = ''nu -c "tofi-drun | swaymsg exec -- ...(\\$in | str trim | split row ' ')"'';

  extraLines = builtins.readFile (
    pkgs.substitute {
      src = ./sway.conf;
      substitutions = [ ];
    }
  );

  wallpaperPath = "${mypkgs.system-wallpapers}/share/wallpapers/system-wallpapers";
in
{

  options.nazarick.gui.sway = {
    enable = lib.mkEnableOption "sway";
  };

  config = lib.mkIf cfg.enable {

    nazarick.gui = {
      gammastep.enable = true;
      swww = {
        enable = true;
        wallpaperPath = wallpaperPath;
      };
    };

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

    home.packages = with pkgs; [
      kdePackages.dolphin
      kdePackages.qqc2-desktop-style # https://discuss.kde.org/t/broken-kde-connect-theme/18451/5
      kdePackages.plasma-integration
      lxqt.pavucontrol-qt
      swayosd # Graphical volume controls
      blueman
      nwg-displays # ~/.config/sway/outputs
      swayidle
      swaysome
      xwaylandvideobridge

      mypkgs.inhibit-bridge

      # Screenies
      grim
      slurp
    ];

    services.kdeconnect = {
      enable = true;
      indicator = true;
      package = pkgs.kdePackages.kdeconnect-kde;
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
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
        };
      };
    };

    xdg.configFile."sway/config.d/swayosd.conf" = {
      enable = true;
      source = ./config.d/swayosd.conf;
    };

    xdg.configFile."sway/config.d/swaysome.conf" = {
      enable = true;
      source = ./config.d/swaysome.conf;
    };

  };
}
