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
  cfg = config.nazarick.bundles.common;
in
{
  options.nazarick.bundles.common = with types; {
    enable = mkBoolOpt false "Enable common configuration.";
  };
  config = mkIf cfg.enable {
    nazarick = {
      tools = {
        sudo = {
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
