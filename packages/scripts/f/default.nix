{
  inputs,
  pkgs,
  system,
  ...
}:
{
  name = "f";
  type = "nu";
  source = ./f.nu;
  dependencies = [
    pkgs.fd
    pkgs.zoxide
  ];
}
