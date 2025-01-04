{
  mylib,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.network.firewall;
in
{

  options.nazarick.network.firewall = {
    enable = mkEnableOption "Enable firewall configuration";
    kdeconnect = mkBoolOpt false "Open KDE Connect's ports";
    nordvpn = mkBoolOpt false "Allow NordVPN's ports";
    syncthing = mkBoolOpt false "Allow syncthing's ports";
  };

  config = mkIf cfg.enable {
    networking.firewall = lib.mkMerge [
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
      (mkIf cfg.syncthing {
        checkReversePath = false;
        allowedTCPPorts = [ 22000 ];
        allowedUDPPorts = [ 22000 ];
      })
    ];
  };
}
