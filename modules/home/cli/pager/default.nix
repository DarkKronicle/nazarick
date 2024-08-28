{
  lib,
  mylib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.cli.pager;
in
{
  options.nazarick.cli.pager = {
    enable = mkEnableOption "ov + bat";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ ov ];

    programs.bat = {
      enable = true;
      config = {
        theme = "catppuccin_mocha";
        pager = "ov -F -H3";
      };
      themes = {
        catppuccin_mocha = {
          src = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/catppuccin/bat/2bafe4454d8db28491e9087ff3a1382c336e7d27/themes/Catppuccin%20Mocha.tmTheme";
            sha256 = "sha256-F4jRaI6KKFvj9GQTjwQFpROJXEVWs47HsTbDVy8px0Q=";
          };
        };
      };
    };

    xdg.configFile."ov/config.yaml" = {
      enable = true;
      source = ./config.yaml;
    };

    home.sessionVariables = {
      PAGER = ''ov'';
      SYSTEMD_PAGERSECURE = ''true'';
      MANPAGER = ''ov --section-delimiter '^[^\\s]' --section-header'';
    };
  };
}
