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
    hostnameColor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {

    xdg.configFile."starship.toml" = {
      enable = true;
      source =
        if cfg.hostnameColor == null then
          ./starship.toml
        else
          (pkgs.substitute {
            src = ./host.toml;
            substitutions = [
              "--replace-fail"
              "@HOSTCOLOR@"
              cfg.hostnameColor
            ];
          });
    };

    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
    };

  };

}
