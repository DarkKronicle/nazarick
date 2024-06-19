{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nazarick.cli.starship;
in
{
  options.nazarick.cli.starship = {
    enable = lib.mkEnableOption "starship";
  };

  config = lib.mkIf cfg.enable {

    xdg.configFile."starship.toml" = {
      enable = true;
      source = ./starship.toml;
    };

    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
    };

  };

}
