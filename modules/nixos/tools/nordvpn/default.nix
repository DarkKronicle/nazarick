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
  cfg = config.nazarick.tools.nordvpn;
  nordvpn-pkg = mypkgs.nordvpn;
in
{
  options.nazarick.tools.nordvpn = {
    enable = mkBoolOpt false "Enable nordvpn.";
  };
  config = mkIf cfg.enable {
    # This makes hosts readable, but it will be reset each time restarted. Works well enough for meshnet tho :)
    environment.etc.hosts.mode = "0644";

    users.groups.nordvpn = { };
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
