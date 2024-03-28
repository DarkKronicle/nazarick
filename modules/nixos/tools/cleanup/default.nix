{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

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
    ];

    systemd.user.timers."cleanup" = {
      wantedBy = [ "default.target" ];
      # TODO: Does this work with impermanence? (does persistent gets persisted)
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
