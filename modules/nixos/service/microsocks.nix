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
    services.microsocks = {
      enable = true;
      ip = "127.0.0.1";
      port = 1080;

    };
  };

}
