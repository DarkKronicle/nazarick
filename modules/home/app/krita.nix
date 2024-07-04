{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.nazarick.app.krita;

in
{
  options.nazarick.app.krita = {
    enable = lib.mkEnableOption "krita";
  };

  config = lib.mkIf cfg.enable { home.packages = with pkgs; [ krita ]; };

}
