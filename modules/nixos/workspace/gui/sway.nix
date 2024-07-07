{
  lib,
  pkgs,
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
    services.gnome.gnome-keyring.enable = lib.mkDefault true;

    # Maybe change this? But sddm with my theme is pretty cool
    services.displayManager.sddm.wayland.enable = true;

    # Majority of stuff is configured in home manager land
    programs.sway = {
      inherit package;
      enable = true;
      extraOptions = [
        "--unsupported-gpu" # not going to use open source :(
      ];
      extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1
      '';
      wrapperFeatures.gtk = true;
    };
  };
}
