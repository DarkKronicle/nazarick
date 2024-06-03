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
  username = config.nazarick.workspace.user.name;
in
{
  specialisation = {
    powersave.configuration = {
      # services.desktopManager.plasma6.enable = lib.mkForce false;
      # services.xserver.desktopManager.lxqt.enable = true;
      home-manager.users.${username}.nazarick = {
        app = {
          mpv = {
            enable = lib.mkForce false;
          };
        };
      };
      nazarick = {
        system = {
          nvidia = {
            enable = lib.mkForce false;
            blacklist = true;
          };
          bluetooth = {
            enable = lib.mkForce false;
          };
          printing = {
            enable = lib.mkForce false;
          };
        };
        workspace.service = {
          spotifyd.enable = lib.mkForce false;
        };
        workspace.gui = {
          steam.enable = lib.mkForce false;
        };
      };
    };
  };
}
