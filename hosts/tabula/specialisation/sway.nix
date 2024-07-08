# This is theoretically a temporary specialisation
{
  options,
  config,
  lib,
  pkgs,
  mylib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  forEachUser = mylib.forEachUser config;
in
{
  specialisation.sway.configuration = {
    # services.desktopManager.plasma6.enable = lib.mkForce false;
    # services.xserver.desktopManager.lxqt.enable = true;
    home-manager.users = lib.mkMerge (
      forEachUser (username: {
        ${username}.nazarick = {
          gui.sway.enable = true;
          gui.qt.enable = true;
          gui.plasma.enable = lib.mkForce false;
        };
      })
    );

    nazarick = {
      workspace.gui = {
        sway.enable = lib.mkForce true;
        sddm = {
          enable = true;
          defaultSession = "sway";
        };
        plasma.enable = lib.mkForce false;
      };
      system.boot.plymouth.enable = lib.mkForce false; # Give me at least some good debug info
    };
  };
}
