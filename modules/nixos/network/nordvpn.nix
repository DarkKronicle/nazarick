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
  };
  config = mkIf cfg.enable {
    # This makes hosts readable, but it will be reset each time restarted. Works well enough for meshnet tho :)
    environment.etc.hosts.mode = "0644";

    users.groups.nordvpn = { };

    nazarick.users.extraGroups = lib.optionals cfg.applyUsers [ "nordvpn" ];

    environment.systemPackages = [ nordvpn-pkg ];
    systemd = {
      services.nordvpn = {
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
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };
    };
  };
}
