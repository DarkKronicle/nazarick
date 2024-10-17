{
  lib,
  config,
  pkgs,
  inputs,
  mylib,
  myvars,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.spotify;
in
{
  options.nazarick.app.spotify = {
    spotify-qt.enable = mkEnableOption "spotify-qt";
  };

  config = mkIf cfg.spotify-qt.enable {
    home.packages = with pkgs; [
      spotify-qt
    ];

    programs.spotify-player = {
      enable = true;
      settings = {
        client_id = myvars.spotify.connectId;
        enable_streaming = "Never";
        theme = "Catppuccin-mocha";
      };
      themes = [
        {
          name = "Catppuccin-mocha";
          palette = {
            background = "#16161D";
            foreground = "#cdd6f4";
            black = "#1e1e2e";
            blue = "#89b4fa";
            cyan = "#89dceb";
            green = "#a6e3a1";
            magenta = "#cba6f7";
            red = "#f38ba8";
            white = "#cdd6f4";
            yellow = "#f9e2af";
            bright_black = "#1e1e2e";
            bright_blue = "#89b4fa";
            bright_cyan = "#89dceb";
            bright_green = "#a6e3a1";
            bright_magenta = "#cba6f7";
            bright_red = "#f38ba8";
            bright_white = "#cdd6f4";
            bright_yellow = "#f9e2af";
          };

          component_style = {
            selection = {
              bg = "#313244";
              modifiers = [ "Bold" ];
            };
            block_title = {
              fg = "Magenta";
            };
            playback_track = {
              fg = "Cyan";
              modifiers = [ "Bold" ];
            };
            playback_album = {
              fg = "Yellow";
            };
            playback_metadata = {
              fg = "Blue";
            };
            playback_progress_bar = {
              bg = "#313244";
              fg = "Green";
            };
            current_playing = {
              fg = "Green";
              modifiers = [ "Bold" ];
            };
            page_desc = {
              fg = "Cyan";
              modifiers = [ "Bold" ];
            };
            table_header = {
              fg = "Blue";
            };
            border = { };
            playback_status = {
              fg = "Cyan";
              modifiers = [ "Bold" ];
            };
            playback_artists = {
              fg = "Cyan";
              modifiers = [ "Bold" ];
            };
            playlist_desc = {
              fg = "#a6adc8";
            };
          };
        }

      ];
    };
  };
}
