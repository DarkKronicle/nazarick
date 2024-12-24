{
  lib,
  config,
  pkgs,
  mylib,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.thunderbird;
in
{
  options.nazarick.app.thunderbird = {
    enable = mkEnableOption "Thunderbird";
  };

  config = mkIf cfg.enable {

    services.flatpak = {
      enable = true;
      update.auto.enable = true;
      packages = [
        "eu.betterbird.Betterbird"
      ];
    };

  };
}
