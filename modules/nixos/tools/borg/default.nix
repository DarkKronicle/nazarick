{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  username = config.nazarick.user.name;
  cfg = config.nazarick.tools.borg;
in
{
  options.nazarick.tools.borg = {
    enable = mkEnableOption "Borg";
  };

  config = mkIf cfg.enable {
    sops.secrets."borg/repository" = {
      owner = username;
    };
    sops.secrets."borg/wifi" = {
      owner = username;
    };
    sops.secrets."borg/password" = {
      owner = username;
    };
    environment.systemPackages = with pkgs; [ borgbackup ];

    systemd.timers."borger" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = false;
      };
    };

    systemd.services."borger" = {
      path = [
        pkgs.borgbackup
        pkgs.nushell
        pkgs.networkmanager # check wifi
        pkgs.nazarick.nordvpn # check wifi pt2
        pkgs.procps
        pkgs.ripgrep
      ];
      script = "${./backup.nu} $(cat ${config.sops.secrets."borg/repository".path}) $(cat ${
        config.sops.secrets."borg/password".path
      }) $(cat ${config.sops.secrets."borg/wifi".path}) ${./exclude.txt}";
      serviceConfig = {
        Type = "oneshot";
        User = username;
      };
    };
  };
}
