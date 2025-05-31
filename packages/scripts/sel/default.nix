{ pkgs, ... }:
{
  name = "sel";
  type = "nu";
  source = ./sel.nu;
  dependencies = with pkgs; [
    niri
    nushell
    tofi
  ];
}
