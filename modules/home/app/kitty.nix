{
  lib,
  config,
  pkgs,
  inputs,
  mylib,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.kitty;
  oldVersion = lib.version == "24.05pre-git";
  themeOpt = if oldVersion then "theme" else "themeFile";
in
{
  options.nazarick.app.kitty = {
    enable = mkEnableOption "Kitty";
  };

  config = mkIf cfg.enable {

    home.sessionVariables = {
      "TERM" = "kitty";
      "TERMINAL" = "kitty";
    };

    programs.kitty = {
      package = pkgs.kitty;
      enable = true;
      settings = {
        font_family = "CaskaydiaCove Nerd Font";
        italic_font = "family='CaskaydiaCove Nerd Font' style='Italic' features=+ss01"; # +ss01 is cursive
        bold_italic_font = "family='CaskaydiaCove Nerd Font' style='Bold Italic' features=+ss01";
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
        tab_title_max_length = 20;
        listen_on = "unix:/tmp/mykitty";

        background_opacity = "0.60";
        cursor_blink_interval = 0;

        # font_size = "11.3";

        background = "#16161D";
        enable_audio_bell = false;

        allow_remote_control = true;
        dynamic_background_opacity = true;
      };
      keybindings = {
        "alt+l" = "next_tab";
        "alt+h" = "previous_tab";
        "alt+x" = "close_tab";
      };
      "${themeOpt}" = "Catppuccin-Mocha";
    };
  };
}
