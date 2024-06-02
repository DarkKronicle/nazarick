{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.workspace.gui.common;
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.workspace.gui.common = {
    enable = lib.mkEnableOption "Common GUI configuration";
  };

  config = lib.mkIf cfg.enable {

    nazarick.workspace.gui = {
      sddm.enable = lib.mkOverride 500 true;
      fonts.enable = lib.mkOverride 500 true;
    };
  };
}
