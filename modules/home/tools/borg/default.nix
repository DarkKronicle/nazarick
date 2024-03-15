{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  user = config.nazarick.user;
  cfg = config.nazarick.tools.borg;
in
{
  options.nazarick.tools.borg = {
    enable = mkEnableOption "Borg";
  };

  config = mkIf cfg.enable { };
}
