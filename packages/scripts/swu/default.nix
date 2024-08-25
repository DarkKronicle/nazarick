{ pkgs, ... }:
{
  name = "swu";
  type = "nu";
  source = ./swu.nu;
  dependencies = with pkgs; [
    swayfx
    nushell
    coreutils
    bash
  ];
}
