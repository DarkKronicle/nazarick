{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.specialisation.powersave;
in
{
  options.nazarick.specialisation.powersave = with types; {
    enable = mkBoolOpt false "Enable powersave specialisation.";
  };
  config = mkIf cfg.enable {
    specialisation = {
      powersave.configuration = {
        # services.desktopManager.plasma6.enable = lib.mkForce false;
        # services.xserver.desktopManager.lxqt.enable = true;
        # TODO: Use $user here
        home-manager.users.darkkronicle.nazarick = {
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
