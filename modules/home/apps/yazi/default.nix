{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.apps.yazi;
in
{
  options.nazarick.apps.yazi = {
    enable = mkEnableOption "Yazi";
  };

  config = mkIf cfg.enable {

    programs.yazi = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        log = {
          enabled = false;
        };
        manager = {
          show_hidden = true;
          sort_by = "natural";
          sort_dir_first = true;
        };
      };
    };
  };
}
