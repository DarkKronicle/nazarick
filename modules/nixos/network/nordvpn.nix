{
  options,
  config,
  lib,
  mylib,
  pkgs,
  mypkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.network.nordvpn;
  nordvpn-pkg = mypkgs.nordvpn;
in
{
  options.nazarick.network.nordvpn = {
    enable = mkBoolOpt false "Enable nordvpn.";
    applyUsers = mkBoolOpt true "Apply nordvpn group to all users";
    autoMeshnetRestart = mkBoolOpt false "Automatically restart meshnet daily";
  };
  config = mkIf cfg.enable {
    # This makes hosts readable, but it will be reset each time restarted. Works well enough for meshnet tho :)
    environment.etc.hosts.mode = "0644";

    users.groups.nordvpn = { };

    nazarick.users.extraGroups = lib.optionals cfg.applyUsers [ "nordvpn" ];

    environment.systemPackages = [ nordvpn-pkg ];
    systemd.services.nordvpn = {
      description = "NordVPN daemon.";
      serviceConfig = {
        ExecStart = "${nordvpn-pkg}/bin/nordvpnd";
        ExecStartPre = ''
          ${pkgs.bash}/bin/bash -c '\
            mkdir -m 700 -p /var/lib/nordvpn; \
            if [ -z "$(ls -A /var/lib/nordvpn)" ]; then \
              cp -r ${nordvpn-pkg}/var/lib/nordvpn/* /var/lib/nordvpn; \
            fi'
        '';
        NonBlocking = true;
        KillMode = "process";
        Restart = "on-failure";
        RestartSec = 5;
        RuntimeDirectory = "nordvpn";
        RuntimeDirectoryMode = "0750";
        Group = "nordvpn";
      };
      # Disable auto starting
      # wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.timers."nordvpn-meshnet-healthcheck" = {
      enable = cfg.autoMeshnetRestart;
      wantedBy = [ "default.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "30m";
        RandomizedDelaySec = "3m";
      };
    };

    systemd.services."nordvpn-meshnet-healthcheck" = {
      script = "${pkgs.iputils}/bin/ping -c 1 ${config.networking.hostName}.nord";
      onFailure = [ "nordvpn-meshnet-restart.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
    };

    systemd.services."nordvpn-meshnet-restart" = {
      # We do the weird boolean stuff so that everything will be triggered even if meshnet is off (want to make sure it's on!)
      # I also just dislike bash bc these cursed things are needed (before you ask, set -e is enabled here)
      script = ''
        echo "Meshnet stopped working! Restarting..."
        ${mypkgs.nordvpn}/bin/nordvpn set meshnet off || true; sleep 3 && ${mypkgs.nordvpn}/bin/nordvpn set meshnet on
        systemctl reset-failed nordvpn-meshnet-healthcheck.service
      '';
      serviceConfig = {
        Type = "oneshot";
        Environment = [
          "HOME=/root" # needs this for some reason...
        ];
      };
    };
  };
}
