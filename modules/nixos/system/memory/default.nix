{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.nazarick.system.memory;
in
{
  options.nazarick.system.memory = {
    enable = mkEnableOption "Enable better memory management";
  };
  config = mkIf cfg.enable {
    services.earlyoom = {
      enable = true;
    };
  };
}
