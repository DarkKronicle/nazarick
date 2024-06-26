{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.system;
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.system = {
    desktop = lib.mkEnableOption "Common desktop system configuration";
    common = lib.mkEnableOption "Common system configuration";
  };

  config.nazarick.system = lib.mkMerge [
    (lib.mkIf cfg.desktop {
      audio.enable = lib.mkOverride 500 true;
      bluetooth.enable = lib.mkOverride 500 true;
      printing.enable = lib.mkOverride 500 true;
    })
    (lib.mkIf cfg.common {
      # boot.enable = lib.mkOverride 450 true;
      memory.enable = lib.mkOverride 450 true;
      disk.enable = lib.mkOverride 450 true;
      misc = {
        enable = lib.mkOverride 450 true;
        system76cpu = lib.mkOverride 450 true;
      };
    })
  ];
}
