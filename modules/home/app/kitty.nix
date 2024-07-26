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
      theme = "Catppuccin-Mocha";
      settings = {
        font_family = "CaskaydiaCove";
        italic_font = "Operator-caskabold";
        bold_italic_font = "Operator-caskabold";
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
        tab_title_max_length = 20;
        listen_on = "unix:/tmp/mykitty";

        background_opacity = "0.75";
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
    };
  };
}
