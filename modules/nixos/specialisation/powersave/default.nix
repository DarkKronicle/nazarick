{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.nazarick) mkBoolOpt;
  cfg = config.nazarick.specialisation.powersave;
  username = config.nazarick.user.name;
in
{
  options.nazarick.specialisation.powersave = {
    enable = mkBoolOpt false "Enable powersave specialisation.";
  };
  config = mkIf cfg.enable {
    specialisation = {
      powersave.configuration = {
        # services.desktopManager.plasma6.enable = lib.mkForce false;
        # services.xserver.desktopManager.lxqt.enable = true;
        home-manager.users.${username}.nazarick = {
          apps = {
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
          apps = {
            spotifyd = {
              enable = lib.mkForce false;
            };
            steam = {
              enable = lib.mkForce false;
            };
          };
        };
      };
    };
  };
}
