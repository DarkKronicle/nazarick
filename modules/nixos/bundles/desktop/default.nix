{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.nazarick) enabled mkBoolOpt;
  cfg = config.nazarick.bundles.desktop;
in
{
  options.nazarick.bundles.desktop = {
    enable = mkBoolOpt false "Enable necessary desktop configuration.";
  };
  config = mkIf cfg.enable {
    nazarick = {
      desktop = {
        sddm = {
          enable = true;
        };
        fonts = {
          enable = true;
        };
      };
      bundles = {
        common = enabled;
      };
      system = {
        printing = {
          enable = true;
        };
        bluetooth = {
          enable = true;
        };
        hardware = {
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
