{
  inputs,
  pkgs,
  system,
  ...
}:
{
  name = "stl";
  type = "nu";
  source = ./stl.nu;
  dependencies = [
    pkgs.systemd
  ];
}
