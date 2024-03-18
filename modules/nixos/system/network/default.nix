{ config, lib, ... }:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.system.network;
in
{
  options.nazarick.system.network = with types; {
    enable = mkBoolOpt false "Enable wifi configuration.";
    kdeconnect = mkBoolOpt false "Open KDE Connect's ports";
    nordvpn = mkBoolOpt false "Allow NordVPN's ports";
  };
  config = mkIf cfg.enable {
    networking.firewall = mkMerge [
      {
        enable = true;
        allowedTCPPortRanges = mkIf cfg.kdeconnect [
          {
            from = 1714;
            to = 1764;
          } # KDE Connect
        ];
        allowedUDPPortRanges = mkIf cfg.kdeconnect [
          {
            from = 1714;
            to = 1764;
          } # KDE Connect
        ];
      }
      (mkIf cfg.nordvpn {
        checkReversePath = false;
        allowedTCPPorts = [ 443 ];
        allowedUDPPorts = [ 1194 ];
      })
    ];
  };
}
