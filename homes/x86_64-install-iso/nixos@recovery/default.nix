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
    };
    tools = {
      nushell = {
        enable = false;
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
    };
  };
}
