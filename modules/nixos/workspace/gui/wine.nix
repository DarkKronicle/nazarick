{
  options,
  config,
  lib,
  mylib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.nazarick.workspace.gui.wine;
in
{
  options.nazarick.workspace.gui.wine = {
    enable = mkBoolOpt false "Enable wine";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ wineWowPackages.stable ]; };
}
