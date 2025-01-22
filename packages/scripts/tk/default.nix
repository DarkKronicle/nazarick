{
  inputs,
  pkgs,
  system,
  ...
}:
{
  name = "tk";
  type = "nu";
  source = ./tk.nu;
  dependencies = [ pkgs.taskwarrior ];
}
