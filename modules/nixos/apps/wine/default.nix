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

  cfg = config.nazarick.apps.wine;
in
{
  options.nazarick.apps.wine = {
    enable = mkBoolOpt false "Enable wine";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ wineWowPackages.stable ]; };
}
