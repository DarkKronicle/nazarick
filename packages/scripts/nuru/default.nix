{ pkgs, ... }:
{
  name = "nuru";
  type = "nu";
  source = ./nuru.nu;
  dependencies = with pkgs; [
    niri
    nushell
  ];
}
