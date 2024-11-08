{
  lib,
  config,
  myvars,
  ...
}:
let
  cfg = config.nazarick.service.tinyproxy;
in
{
  options.nazarick.service.tinyproxy = {
    enable = lib.mkEnableOption "tinyproxy";
  };

  config = lib.mkIf cfg.enable {
    services.tinyproxy = {
      enable = true;
      settings = {
        # Only bind on localhost
        Port = 47142;
        Listen = "127.0.0.1";
        Allow = "127.0.0.1";
      };

    };
  };

}
