{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.core.common;
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.core.common = {
    enable = lib.mkEnableOption "Common core configuration";
  };

  config = lib.mkIf cfg.enable { nazarick.core.nix.enable = lib.mkOverride 500 true; };
}
