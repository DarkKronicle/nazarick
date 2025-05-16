{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nazarick.app.ollama;

  ollama = pkgs.ollama-cuda;
in
{
  options.nazarick.app.ollama = {
    enable = lib.mkEnableOption "ollama";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      ollama
    ];

    services.ollama = {
      enable = true;
      # This should do cuda without the option here
      package = ollama;
    };
  };

}
