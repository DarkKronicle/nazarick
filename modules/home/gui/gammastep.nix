{
  pkgs,
  lib,
  mylib,
  config,
  ...

}:
let
  cfg = config.nazarick.gui.swww;
in
{
  options.nazarick.gui.gammastep = {
    enable = lib.mkEnableOption "gammastep";
  };

  config = lib.mkIf cfg.enable {
    services.gammastep = {
      enable = true;
      # This is not dusk/dawn, just the time I like for this
      dawnTime = "5:00-6:00";
      duskTime = "21:30-23:00";

      temperature = {
        day = 6500;
        night = 4500;
      };

      settings.general = {
        fade = 1;
        brightness-day = "1.0";
        brightness-night = "0.7";
      };
    };
  };

}
