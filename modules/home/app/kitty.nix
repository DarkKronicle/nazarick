{
  lib,
  config,
  pkgs,
  inputs,
  mylib,
  system,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.kitty;
  oldVersion = lib.hasPrefix "24.05" lib.version;
  themeOpt = if oldVersion then "theme" else "themeFile";

  kittyScrollback = pkgs.fetchFromGitHub {
    owner = "mikesmithgh";
    repo = "kitty-scrollback.nvim";
    rev = "d51725a6b71d65dd9df83ddc07903de2fb2736ee";
    hash = "sha256-K2etlw89afHYR791keUF5+BBRybfp2mKaVYWigEXczs=";
  };

  kittyScrollbackSubstituted = pkgs.substitute {
    src = "${kittyScrollback}/python/kitty_scrollback_nvim.py";
    substitutions = [
      "--replace-fail"
      "which('nvim')"
      "which('nvim-cats')"
    ];
  };

  kittyScrollbackPython = pkgs.stdenvNoCC.mkDerivation {
    name = "kitty_scrollback_nvim.py";
    dontUnpack = true;
    enableParallelBuilding = true;
    installPhase = ''
      mkdir -p $out/python
      cp ${kittyScrollbackSubstituted} $out/python/kitty_scrollback_nvim.py
      cp ${kittyScrollback}/python/loading.py $out/python/loading.py
      cp ${kittyScrollback}/python/kitty_scroll_prompt.py $out/python/kitty_scroll_prompt.py
      cp ${kittyScrollback}/python/kitty_debug_config.py $out/python/kitty_debug_config.py
    '';
  };
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
      extraConfig = ''
        # kitty-scrollback.nvim Kitten alias
        action_alias kitty_scrollback_nvim kitten ${kittyScrollbackPython}/python/kitty_scrollback_nvim.py

        # Browse scrollback buffer in nvim
        map kitty_mod+h kitty_scrollback_nvim
        # Browse output of the last shell command in nvim
        map kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
        # Show clicked command output in nvim
        mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
      '';
    };
  };
}
