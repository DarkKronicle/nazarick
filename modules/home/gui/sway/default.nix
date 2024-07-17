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
      substitutions = [
        "--replace-fail"
        "##LAUNCHER##"
        launcher
        "--replace-fail"
        "##LOCKCMD##"
        "swaylock -f -c 000000"
      ];
    }
  );

  toml = pkgs.formats.toml { };

  wallpaperConf = toml.generate "wpaperd.toml" {
    # Can have specific displays... DP-1...
    default = {
      path = "${mypkgs.system-wallpapers}/share/wallpapers/system-wallpapers";
      duration = "30m";
      sorting = "random";
      mode = "center";
    };
  };
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
      checkConfig = false; # Annoying with swayfx
      extraConfig = extraLines;
      systemd.enable = true;
      config = {
        menu = launcher;
        terminal = "kitty";
        keybindings = { }; # Remove default
        bars = [ ]; # Remove default
      };
    };

    home.packages = with pkgs; [
      kdePackages.dolphin
      lxqt.pavucontrol-qt
      wpaperd
      swayosd # Graphical volume controls
      blueman
      nwg-displays # ~/.config/sway/outputs
      swaylock
      swayidle
      swaysome
      xwaylandvideobridge
      # perl538Packages.Apppapersway # Slightly buggy :/ I'll try this again

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

    xdg.configFile."wpaperd/config.toml" = {
      enable = true;
      source = wallpaperConf;
    };

    xdg.configFile."sway/config.d/swayosd.conf" = {
      enable = true;
      source = ./config.d/swayosd.conf;
    };

    xdg.configFile."sway/config.d/swaysome.conf" = {
      enable = true;
      source = ./config.d/swaysome.conf;
    };

    services.dunst = {
      enable = true;
      iconTheme = {
        name = "Fluent-dark";
        package = pkgs.fluent-icon-theme;
      };
    };
  };
}
