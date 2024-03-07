{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.tools.nushell;
in
{
  options.nazarick.tools.nushell = {
    enable = mkEnableOption "Nushell";
  };

  config = mkIf cfg.enable {
    home.file.".config/starship.toml".source = ./starship/starship.toml;
    programs = {
      nushell = {
        enable = true;
        # The overlay is applied here
        package = pkgs.nushell;
      };

      starship = {
        enable = true;
        enableNushellIntegration = true;
      };

      atuin = {
        enable = true;
        package = pkgs.atuin;
        enableNushellIntegration = true;
        settings = {
          inline_height = 15;
          style = "compact";
        };
      };
    };
  };
}
