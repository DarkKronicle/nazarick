{ options, config, lib, pkgs, ... }:

with lib;
with lib.nazarick;
let
  cfg = config.nazarick.apps.wine;
in
{
  options.nazarick.apps.wine = with types; {
    enable = mkBoolOpt false "Enable wine";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable
    ];
  };

}
