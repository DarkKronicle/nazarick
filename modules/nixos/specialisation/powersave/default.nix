{
  options,
    config,
    lib,
    pkgs,
    ...
}:
{
  config = {
    specialisation = {
      powersave.configuration = {
        # services.xserver.desktopManager.plasma6.enable = lib.mkForce false;
        # services.xserver.desktopManager.lxqt.enable = true;
        home-manager.users.darkkronicle.nazarick = {
          apps = {
            mpv = { enable = lib.mkForce false; };
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
