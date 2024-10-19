{
  pkgs,
  config,
  lib,
  ...
}:
let

  cfg = config.nazarick.gui.warpd;

in
{

  options.nazarick.gui.warpd = {
    enable = lib.mkEnableOption "warpd";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.warpd ];

    xdg.configFile."warpd/config" = {
      text = ''
        normal_system_cursor: 1
      '';
      enable = true;
    };

  };

}
