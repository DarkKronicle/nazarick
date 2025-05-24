{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nazarick.app.obs;
in
{
  options.nazarick.app.obs = {
    enable = lib.mkEnableOption "obs";
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      package = (
        pkgs.obs-studio.override {
          cudaSupport = true;
        }
      );
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vaapi
        obs-gstreamer
      ];
    };

  };

}
