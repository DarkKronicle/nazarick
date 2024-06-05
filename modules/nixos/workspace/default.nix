{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.workspace.common;
in
{
  options.nazarick.workspace.common = {
    enable = lib.mkEnableOption "Package groups";
    drive = mylib.mkBoolOpt true "Drive tools";
  };

  imports = mylib.scanPaths ./.;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = (
      lib.optionals cfg.drive (
        with pkgs;
        [
          gparted
          ntfs3g
          kdePackages.partitionmanager
        ]
      )
    );
  };
}
