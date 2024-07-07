{
  lib,
  pkgs,
  mypkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.nazarick.workspace.gui.sway;

  package = pkgs.swayfx;
in
{
  options.nazarick.workspace.gui.sway = {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {
    # Brightness/volume
    nazarick.users.extraGroups = [ "video" ];
    programs.light.enable = true;

    # Don't love gnome stuff, but works well enough here. Another option is keepassxs, 
    # that won't autostart

    # Doesn't work well with sddm I think
    # https://github.com/NixOS/nixpkgs/issues/86884
    services.gnome.gnome-keyring.enable = lib.mkDefault true;
    programs.seahorse.enable = true;

    # Maybe change this? But sddm with my theme is pretty cool
    services.displayManager.sddm.wayland.enable = true;

    environment.systemPackages = with pkgs; [ kdePackages.qtwayland ];

    # Majority of stuff is configured in home manager land
    programs.sway = {
      inherit package;
      enable = true;
      extraOptions = [
        "--unsupported-gpu" # not going to use open source :(
      ];
      extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1
        export QT_QPA_PLATFORM=wayland
        export QT_QPA_PLATFORMTHEME=qt5ct
        export _JAVA_AWT_WM_NONREPARENTING=1
      ''; # QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      wrapperFeatures.gtk = true;
    };
  };
}
