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

  homeCfg = config.wayland.windowManager.sway;
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
      wpaperd
      perl538Packages.Apppapersway
      swayosd # Graphical volume controls
      blueman
    ];

    xdg.configFile."wpaperd/config.toml" = {
      enable = true;
      source = wallpaperConf;
    };

    xdg.configFile."sway/config.d" = {
      enable = true;
      recursive = true;
      source = ./config.d;
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
