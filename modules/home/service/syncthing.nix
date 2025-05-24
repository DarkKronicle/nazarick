{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nazarick.service.syncthing;
in
{
  options.nazarick.service.syncthing = {
    enable = lib.mkEnableOption "syncthing";
  };

  config = lib.mkIf cfg.enable {

    services.syncthing.enable = true;

    home.packages = with pkgs; [
      syncthing
    ];
  };
}
