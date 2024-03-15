{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.tools.nordvpn;
in
{
  options.nazarick.tools.nordvpn = with types; {
    enable = mkBoolOpt false "Enable nordvpn.";
  };
  config = mkIf cfg.enable {
    # This makes hosts readable, but it will be reset each time restarted. Works well enough for meshnet tho :)
    environment.etc.hosts.mode = "0644";

    users.groups.nordvpn = { };
    environment.systemPackages = with pkgs; [ nazarick.nordvpn ];
    systemd = {
      services.nordvpn = {
        description = "NordVPN daemon.";
        serviceConfig = {
          ExecStart = "${pkgs.nazarick.nordvpn}/bin/nordvpnd";
          ExecStartPre = ''
            ${pkgs.bash}/bin/bash -c '\
              mkdir -m 700 -p /var/lib/nordvpn; \
              if [ -z "$(ls -A /var/lib/nordvpn)" ]; then \
                cp -r ${pkgs.nazarick.nordvpn}/var/lib/nordvpn/* /var/lib/nordvpn; \
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
    networking.firewall = {
      enable = true;
      checkReversePath = false;
      allowedTCPPorts = [ 443 ];
      allowedUDPPorts = [ 1194 ];
    };
  };
}
