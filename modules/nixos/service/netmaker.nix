{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.service.netmaker;
in
{
  options.nazarick.service.netmaker = {
    enable = lib.mkEnableOption "netmaker";
  };

  config = lib.mkIf cfg.enable {
    services.netclient = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [
      netclient
    ];
  };

}
