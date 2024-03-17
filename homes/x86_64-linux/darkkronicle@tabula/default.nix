{
  lib,
  pkgs,
  config,
  osConfig ? { },
  format ? "unknown",
  ...
}:
with lib.nazarick;
{
  home.packages = with pkgs; [ neofetch ];
  nazarick = {
    plasma = {
      enable = true;
      noBorders = true;
    };
    tools = {
      git = {
        enable = true;
        userEmail = "darkkronicle@gmail.com";
        userName = "DarkKronicle";
      };
      nushell = {
        enable = true;
      };
      playerctl = {
        enable = true;
      };
      easyeffects = {
        enable = true;
      };
    };

    apps = {
      firefox = {
        enable = true;
      };
      kitty = {
        enable = true;
      };
      yazi = {
        enable = true;
      };
      mpv = {
        enable = true;
      };
      defaults = {
        enable = true;
      };
      neovim = {
        enable = true;
      };
    };
  };
}
