{
  inputs,
  pkgs,
  system,
  ...
}:
{
  name = "nux";
  type = "nu";
  source = ./nux.nu;
  dependencies = [ inputs.nix-index-database.packages.${system}.nix-index-with-db ];
}
