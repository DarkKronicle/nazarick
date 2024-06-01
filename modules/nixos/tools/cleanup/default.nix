{
  lib,
  config,
  pkgs,
  mylib,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  user = config.nazarick.user.name;
  cfg = config.nazarick.tools.cleanup;
in
{
  options.nazarick.tools.cleanup = {
    enable = mkEnableOption "Cleanup";
  };

  config = mkIf cfg.enable {
    systemd.user.tmpfiles.users.${user}.rules = [
      "d /home/${user}/Downloads - - - 14d"
      "d /home/${user}/.vim/undodir - - - 14d"

      "d /home/${user}/.cache/thumbnails/large - - - 7d"
      "d /home/${user}/.cache/thumbnails/normal - - - 7d"
      "d /home/${user}/.cache/thumbnails/x-large - - - 7d"
      "d /home/${user}/.cache/thumbnails/xx-large - - - 7d"
      "d /home/${user}/.cache/yazi - - - 7d"

      "d /home/${user}/.local/state/mpv/watch_later - - - 14d"
    ];

    # There *is* the service systemd-tmpfiles-clean, but I 
    # can't figure out how to enable it by default. So this will
    # have to do
    # TODO: Add another service for boot, but I currently don't use that
    systemd.user.timers."tmpfiles-cleanup" = {
      wantedBy = [ "default.target" ]; # activate when stuff is ready
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };

    systemd.user.services."tmpfiles-cleanup" = {
      script = "systemd-tmpfiles --user --clean";
      serviceConfig = {
        Type = "oneshot";
      };
    };

    systemd.user.timers."cleanup" = {
      wantedBy = [ "default.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };

    systemd.user.services."cleanup" = {
      script = "${pkgs.gtrash}/bin/gtrash prune --day 7 --force";
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
}
