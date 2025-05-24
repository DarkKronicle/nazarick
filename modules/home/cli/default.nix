{
  config,
  lib,
  mylib,
  pkgs,
  mypkgs,
  inputs,
  system,
  ...
}:
let
  cfg = config.nazarick.cli.common;
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.cli.common = {
    enable = lib.mkEnableOption "Common CLI configuration";
    fun = lib.mkEnableOption "Fun CLI configuration";
    misc = lib.mkEnableOption " Misc configuration";
  };

  config = lib.mkIf cfg.enable {

    home.packages = import (mylib.relativeToRoot "modules/shared/cli.nix") { inherit pkgs mypkgs; };

    nazarick.cli = {
      pager.enable = lib.mkOverride 500 true;
      starship.enable = lib.mkOverride 500 true;
    };

  };
}
