{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nazarick.security.firejail;
in
{
  options.nazarick.security.firejail = {
    enable = mkEnableOption "firejail";
  };

  config = mkIf cfg.enable {
    # Make sure system level firejail is enabled
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        firefox = {
          executable = "${config.programs.firefox.finalPackage}/bin/firefox";
          profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
          extraArgs = [
            "--ignore=no-root"
            # "--browser-allow-drm=yes"
            ''--ignore=noexec ''${HOME}''
            ''--ignore=noexec ''${RUNUSER}''
            ''--whitelist=''${HOME}/.config/tridactyl''
            "--dbus-user.own=org.mpris.MediaPlayer2.plasma-browser-integration"
            "--dbus-user.talk=org.kde.JobViewServer"
            "--dbus-user.talk=org.kde.kuiserver"
            "--dbus-user.talk=org.freedesktop.portal.Desktop"
            "--dbus-user.talk=org.freedesktop.portal.Desktop"
            "--whitelist=/run/current-system/sw/bin/swaymsg" # I can't get this to be a wildcard, so just this will work
            ''--whitelist=''${RUNUSER}/sway-ipc*''
          ];
        };
        # HD2 don't work :(
        # steam = {
        # executable = "${pkgs.steam}/bin/steam";
        # profile = "${pkgs.firejail}/etc/firejail/steam.profile";
        # };
        # steam-run = {
        # executable = "${pkgs.steam}/bin/steam-run";
        # profile = "${pkgs.firejail}/etc/firejail/steam.profile";
        # };
        prismlauncher = {
          executable = "${pkgs.prismlauncher}/bin/prismlauncher";
          profile = ./firejail-profiles/prismlauncher.profile;
        };
        brave = {
          executable = "${pkgs.brave}/bin/brave";
          profile = "${pkgs.firejail}/etc/firejail/brave.profile";
        };
        vesktop = {
          executable = "${pkgs.vesktop}/bin/vesktop";
          profile = "${pkgs.firejail}/etc/firejail/discord.profile";
          extraArgs = [ ''--whitelist=''${HOME}/.config/vesktop'' ];
        };
      };
    };
  };
}
