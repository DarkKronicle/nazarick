{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.tools.ov;
in
{
  options.nazarick.tools.ov = {
    enable = mkEnableOption "ov";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ ov ];

    home.file.".config/ov/config.yaml" = {
      source = ./config.yaml;
    };

    nazarick.home.environmentVariables = {
      PAGER = ''"bat"'';
      SYSTEMD_PAGERSECURE = ''"true"'';
      MANPAGER = ''"ov --section-delimiter '^[^\\s]' --section-header"'';
    };
  };
}
