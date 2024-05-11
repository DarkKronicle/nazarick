{
  lib,
  pkgs,
  config,
  osConfig ? { },
  format ? "unknown",
  ...
}:
{
  home.packages = with pkgs; [ neofetch ];
  nazarick = {
    plasma = {
      enable = true;
      panels = {
        enable = true;
      };
    };
    tools = {
      nushell = {
        enable = true;
      };
      pager = {
        enable = true;
      };
      fcitx = {
        enable = true;
      };
    };

    apps = {
      firefox = {
        enable = true;
        userCss = false;
      };
      kitty = {
        enable = true;
      };
      yazi = {
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
