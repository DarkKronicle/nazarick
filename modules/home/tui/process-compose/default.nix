{
  lib,
  mylib,
  pkgs,
  config,
  ...
}:
let

  cfg = config.nazarick.tui.zellij;

in
{
  options.nazarick.tui.process-compose = {
    enable = lib.mkEnableOption "process-compose";
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile = {
      "process-compose/settings.yaml" = {
        enable = true;
        source = ./settings.yaml;
      };
      "process-compose/theme.yaml" = {
        enable = true;
        source = ./theme.yaml;
      };
    };
  };
}
