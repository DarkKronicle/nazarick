{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.nazarick.gui.mars;
in
{
  options.nazarick.gui.mars = {
    enable = lib.mkEnableOption "mars-mips";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      mars-mips
    ];
  };

}
