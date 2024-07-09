{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.nazarick.workspace.gui.plasma;
in
{
  options.nazarick.workspace.gui.plasma = {
    enable = mkEnableOption "Enable plasma";
  };

  config = mkIf cfg.enable {

    environment.plasma6.excludePackages = [
      pkgs.kdePackages.kwallet # Gnome keyring bc other things use that
      pkgs.kdePackages.kwallet-pam
      pkgs.kdePackages.kwalletmanager
    ];

    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
    security.pam.services.login.kwallet.enable = lib.mkForce false;
    security.pam.services.kde.kwallet.enable = lib.mkForce false;
    security.pam.services.kde.enableGnomeKeyring = true;

    # Prevents conflict
    programs.ssh.askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

    # Auto start won't be auto starting
    systemd.user.services."gnome-keyring-secret" = {
      wantedBy = [ "graphical-session-pre.target" ];
      description = "Gnome Keyring Daemon";
      script = "/run/wrappers/bin/gnome-keyring-daemon --start --components=secrets";
    };
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;

    xdg.portal = {
      enable = true;
      gtkUsePortal = true;
      # wlr.enable = true;
      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [
            "kde"
            "gtk"
            # "wlr"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
    };
  };
}
