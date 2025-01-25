{
  lib,
  config,
  ...
}:
let
  cfg = config.nazarick.service.netbird;
in
{
  options.nazarick.service.netbird = {
    enable = lib.mkEnableOption "netbird";
  };

  config = lib.mkIf cfg.enable {
    services.netbird = {
      enable = true;
      tunnels.wt0 = { };
    };

    systemd.services.netbird-wt0-restart = {
      wantedBy = [ "sleep.target" ];
      after = [ "sleep.target" ];

      description = "Restart netbird after suspend";

      script = "systemctl restart netbird-wt0";

      serviceConfig = {
        Type = "oneshot";
      };
    };

  };

}
