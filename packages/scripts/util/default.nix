{ pkgs, ... }:
{
  name = "util";
  type = "nu";
  source = ./util.nu;
  dependencies = with pkgs; [
    imagemagick
  ];
}
