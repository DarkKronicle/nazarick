{
  options,
  config,
  mylib,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.nazarick.system.disk;
in
{
  options.nazarick.system.disk = {
    enable = mkBoolOpt false "Enable disks";
  };

  config = mkIf cfg.enable {
    services.udisks2 = {
      enable = true;
    };
  };
}
