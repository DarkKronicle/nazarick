{ pkgs, ... }:
{
  name = "xpress";
  type = "nu";
  source = ./xpress.nu;
  dependencies = with pkgs; [
    crabz
    xz
    zstd
    unzip
    gnutar
  ];
}
