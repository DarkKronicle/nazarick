{
  lib,
  pkgs,
  config,
  osConfig ? {},
  format ? "unknown",
  ...
}:
with lib.nazarick; {
  nazarick = {
    tools = {
      git = {
        enable = true;
        userEmail = "darkkronicle@gmail.com";
        userName = "DarkKronicle";
      };  
    };
  };
}
