{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.nazarick) mkBoolOpt;

  cfg = config.nazarick.bundles.common;
in
{
  options.nazarick.bundles.common = {
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
