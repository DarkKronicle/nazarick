{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  user = config.nazarick.user;
  cfg = config.nazarick.tools.borg;
in
{
  options.nazarick.tools.borg = {
    enable = mkEnableOption "Borg";
  };

  config = mkIf cfg.enable {
    sops.secrets."borg/repository" = {
      owner = "darkkronicle";
    };
    sops.secrets."borg/wifi" = {
      owner = "darkkronicle";
    };
    sops.secrets."borg/password" = {
      owner = "darkkronicle";
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
      ];
      script = "${./backup.nu} $(cat ${config.sops.secrets."borg/repository".path}) $(cat ${
        config.sops.secrets."borg/password".path
      }) $(cat ${config.sops.secrets."borg/wifi".path}) ${./exclude.txt}";
      serviceConfig = {
        Type = "oneshot";
        User = "darkkronicle";
      };
    };
  };
}
