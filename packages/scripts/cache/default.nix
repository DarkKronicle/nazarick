{
  inputs,
  pkgs,
  system,
  ...
}:
{
  name = "cache";
  type = "nu";
  source = ./cache.nu;
  dependencies = [ ];
}
