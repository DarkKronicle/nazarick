{
  lib,
  config,
  pkgs,
  mylib,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.core.nix;
in
{
  options.nazarick.core.nix = {
    enable = mkEnableOption "Nix configuration";
  };

  config = mkIf cfg.enable {
    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enable = true;
  };
}
