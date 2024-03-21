{
  lib,
  pkgs,
  config,
  ...
}:
with lib.nazarick;
{

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
      kdeconnect = {
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
