{
  options,
  config,
  mylib,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.system.audio;
in
{
  options.nazarick.system.audio = {
    enable = mkBoolOpt false "Enable audio support.";
    pipewire = mkBoolOpt false "Enable pipewire instead of pulseaudio";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      #jack.enable = true;
    };
  };
}
