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
  substitutions = [
    "--replace-fail"
    "@NIX_SMALL_DB@"
    (pkgs.linkFarm "nix-index-small-database" {
      files = inputs.nix-index-database.packages.${system}.nix-index-small-database;
    })
  ];
}
