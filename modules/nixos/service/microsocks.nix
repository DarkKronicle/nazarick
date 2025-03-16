{
  lib,
  config,
  myvars,
  ...
}:
let
  cfg = config.nazarick.service.microsocks;
in
{
  options.nazarick.service.microsocks = {
    enable = lib.mkEnableOption "microsocks";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."microsocks/password" = { };
    services.microsocks = {
      enable = true;
      ip = "10.200.0.1";
      port = 1080;
      disableLogging = true;
      authUsername = "darkkronicle";
      authPasswordFile = config.sops.secrets."microsocks/password".path;
    };

    systemd.services.microsocks = {
      wants = [
        "network-namespaces-init.service"
      ];

      after = [
        "network-namespaces-init.service"
      ];
    };
  };

}
