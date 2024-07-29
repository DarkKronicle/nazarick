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

    # services.gnome-keyring.enable = true;

    nazarick.gui.swww = {
      enable = true;
      wallpaperPath = wallpaperPath;
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
      settings = {
        color = "000000";
        fade-in = 0.2;
        clock = true;
        indicator = true;
        text-clear = "(×_×;）";
        text-wrong = "（/＞□＜）/亠亠";
        text-ver = "｢(ﾟﾍﾟ)";
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
      # perl538Packages.Apppapersway # Slightly buggy :/ I'll try this again

      mypkgs.inhibit-bridge

      # Screenies
      grim
      slurp
    ];

    services.gammastep = {
      enable = true;
      # This is not dusk/dawn, just the time I like for this
      dawnTime = "21:30-23:00";
      duskTime = "5:00-6:00";

      temperature = {
        day = 6500;
        night = 4500;
      };

      settings = {
        fade = 1;
        brightness-day = 1.0;
        brightness-night = 0.7;
      };
    };

    services.kdeconnect = {
      enable = true;
      indicator = true;
      package = pkgs.kdePackages.kdeconnect-kde;
    };

    home.sessionVariables = {
      "GTK_USE_PORTAL" = "1";
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
