{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.apps.kitty;
in
{
  options.nazarick.apps.kitty = {
    enable = mkEnableOption "Kitty";
  };

  config = mkIf cfg.enable {

    programs.kitty = {
      enable = true;
      theme = "Catppuccin-Mocha";
      settings = {
        font_family = "CaskaydiaCove";
        italic_font = "Operator-caskabold";
        bold_italic_font = "Operator-caskabold";
      };
    };

  };
}
