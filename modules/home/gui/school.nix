{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.nazarick.gui.school;
in
{
  options.nazarick.gui.school = {
    enable = lib.mkEnableOption "school applications";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      eagle
    ];
  };

}
