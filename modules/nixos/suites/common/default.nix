{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.suites.common;
in
{
  options.nazarick.suites.common = with types; {
    enable = mkBoolOpt false "Enable common configuration.";
  };
  config = mkIf cfg.enable {
    nazarick = {
      appearance = {
        fonts = {
          enable = true;
        };
      };
      system = {
        nix = {
          enable = true;
        };
      };
    };
  };
}
