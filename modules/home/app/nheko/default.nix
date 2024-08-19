{
  lib,
  mylib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.nheko;
in
{
  options.nazarick.app.nheko = {
    enable = mkEnableOption "nheko";
  };

  config = mkIf cfg.enable {
    nixpkgs.config.permittedInsecurePackages = [
      # Nheko https://github.com/Nheko-Reborn/nheko/issues/1786
      # TODO: remove
      "olm-3.2.16"
    ];
    home.packages = [ pkgs.nheko ];
  };
}
