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
    };

    apps = {
      firefox = {
        enable = true;
      };
      kitty = {
        enable = true;
      };
    };
  };
}
