{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nazarick.workspace.gui.fcitx;
in
{
  options.nazarick.workspace.gui.fcitx = {
    enable = mkEnableOption "fcitx5 for japanese input";
  };

  config = mkIf cfg.enable {
    # NOTE: On KDE make sure to not set it to the wayland version
    # it will launch `/nix/store/...fcitx`, we want the one with 
    # addons. Adding a custom desktop file could fix this issue,
    # but for now there isn't really anything different between
    # the 2 versions

    # Also there's an autostart script for fcitx5, but that gets
    # applied after kwin so it will just stop (which is good)
    # app-org.fcitx.Fcitx5@autostart.service
    # this is more a problem with nix, idk there may be a way
    # to get around this, but it will be annoying
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5 = {
        plasma6Support = true;
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];
      };
    };
  };
}
