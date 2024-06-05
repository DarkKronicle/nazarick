{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nazarick.workspace.security.firejail;
in
{
  options.nazarick.workspace.security.firejail = {
    enable = mkEnableOption "firejail";
  };

  config = mkIf cfg.enable {
    programs.firejail = {
      enable = true;
    };
  };
}
