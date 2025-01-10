{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nazarick.security.firejail;

  firejail-nightly = pkgs.fetchFromGitHub {
    owner = "netblue30";
    repo = "firejail";
    rev = "92137f808758cacbd91f876b895ffa681fa79aa0";
    hash = "sha256-JrdPgjxlbKDWShZGg8pLZWmJW0UBnk12tNy0GbjOGpU=";
  };
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
            ''--noblacklist=''${RUNUSER}/app''
            ''--mkdir=''${RUNUSER}/app/org.keepassxc.KeePassXC''
            ''--whitelist=''${RUNUSER}/app/org.keepassxc.KeePassXC''
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
          extraArgs = [
            ''--whitelist=''${HOME}/.config/vesktop''
            # Open files and urls
            "--dbus-user.talk=org.freedesktop.portal.OpenURI.*"
            "--dbus-user.talk=org.freedesktop.portal.Desktop"
          ];
        };
        # nheko = {
        # executable = "${pkgs.nheko}/bin/nheko";
        # profile = "${pkgs.firejail}/etc/firejail/nheko.profile";
        # extraArgs = [
        # ''--dbus-user.talk=org.freedesktop.Notifications''
        # # Open files and urls
        # "--dbus-user.talk=org.freedesktop.portal.OpenURI.*"
        # "--dbus-user.talk=org.freedesktop.portal.Desktop"
        # ];
        # };
        # okular = {
        # executable = "${pkgs.okular}/bin/okular";
        # profile = "${pkgs.firejail}/etc/firejail/okular.profile";
        # };
        # FIX: dolphin also wrapped

        # dolphin = {
        # executable = "${pkgs.dolphin}/bin/dolphin";
        # profile = "${pkgs.firejail}/etc/firejail/dolphin.profile";
        # };
        gimp = {
          executable = "${pkgs.gimp}/bin/gimp";
          profile = "${pkgs.firejail}/etc/firejail/gimp.profile";
        };
        krita = {
          executable = "${config.nazarick.app.krita.package}/bin/krita";
          profile = "${pkgs.firejail}/etc/firejail/krita.profile";
          extraArgs = [
            ''--noblacklist=''${HOME}/.config/krita'' # Custom wrapped location
          ];
        };
        # libreoffice = {
        # executable = "${pkgs.libreoffice-qt}/bin/libreoffice";
        # profile = "${pkgs.firejail}/etc/firejail/libreoffice.profile";
        # };
        mumble = {
          executable = "${pkgs.mumble}/bin/mumble";
          profile = "${pkgs.firejail}/etc/firejail/mumble.profile";
        };
        # ark = {
        # executable = "${pkgs.kdePackages.ark}/bin/ark";
        # profile = "${pkgs.firejail}/etc/firejail/ark.profile";
        # };
        mpv = {
          executable = "${config.programs.mpv.package}/bin/mpv";
          profile = "${firejail-nightly}/etc/profile-m-z/mpv.profile";
          extraArgs = [
            ''--include=${pkgs.firejail}/etc/firejail/allow-bin-sh.inc''
            "--dbus-user=filter"
            "--dbus-user.talk=org.mpris.MediaPlayer2.*"
            "--dbus-user.own=org.mpris.MediaPlayer2.mpv"
            "--private-bin=bash,chmod,echo,ps,socat,tail,uname"
            "--ignore=noexec /tmp"
            "--ignore=dbus-user none"
          ];
        };
      };
    };
  };
}
