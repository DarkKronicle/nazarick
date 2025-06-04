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
    services.netbird.clients.default = {
      port = 51820;
      interface = "wt0";
      name = "netbird";
      hardened = false;
      environment = {
        NB_ENABLE_EXPERIMENTAL_LAZY_CONN = "true";
      };
    };

    systemd.services.netbird-wt0-restart = {
      wantedBy = [ "sleep.target" ];
      after = [ "sleep.target" ];

      description = "Restart netbird after suspend";

      script = "systemctl restart netbird";

      serviceConfig = {
        Type = "oneshot";
      };
    };

  };

}
