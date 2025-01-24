{
  lib,
  config,
  pkgs,
  mylib,
  mypkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.workspace.service.borg;
in
{
  options.nazarick.workspace.service.borg = {
    enable = mkEnableOption "Borg";

    sshFile = lib.mkOption {
      description = "Path to grab the ssh key from, can be runtime or nix store (probably shouldn't be store)";
      type = lib.types.str;

    };
  };

  config = mkIf cfg.enable {
    sops.secrets."borg/repository" = { };
    sops.secrets."borg/password" = { };
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
        pkgs.openssh
        pkgs.nushell
        pkgs.networkmanager # check wifi
        mypkgs.nordvpn # check wifi pt2
        pkgs.procps
        pkgs.ripgrep
      ];
      script = ''BORG_RSH="ssh -i ${cfg.sshFile}" HOME=/root ${./backup.nu} $(cat ${
        config.sops.secrets."borg/repository".path
      }) $(cat ${config.sops.secrets."borg/password".path}) ${./exclude.txt}'';
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
}
