{
  lib,
  pkgs,
  config,
  osConfig ? {},
  format ? "unknown",
  ...
}:
with lib.nazarick; {
  home.packages = with pkgs; [
    neofetch
  ];
  nazarick = {
    tools = {
      git = {
        enable = true;
        userEmail = "darkkronicle@gmail.com";
        userName = "DarkKronicle";
      };  
      nushell = {
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
    };
  };
}
