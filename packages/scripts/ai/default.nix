{
  inputs,
  pkgs,
  system,
  ...
}:
{
  name = "ai";
  type = "nu";
  source = ./ai.nu;
  dependencies = [
    pkgs.rich-cli
    pkgs.aichat
  ];
}
