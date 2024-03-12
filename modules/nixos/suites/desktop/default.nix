{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick; let
  cfg = config.nazarick.suites.desktop;
in {
  options.nazarick.suites.desktop = with types; {
    enable = mkBoolOpt false "Enable necessary desktop configuration.";
  };
  config = mkIf cfg.enable {
    nazarick = {
      suites = {
        common = enabled;
      };
      system = {
        printing = {
          enable = true;
        };
        bluetooth = {
          enable = true;
        };
        power = {
          enable = true;
        };
        audio = {
          enable = true;
          pipewire = true;
        };
      };
    };
  };
}
