{
  lib,
  pkgs,
  mypkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.nazarick.workspace.gui.desktop.niri;
in
{
  options.nazarick.workspace.gui.desktop.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {

    programs.niri = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
  };
}
